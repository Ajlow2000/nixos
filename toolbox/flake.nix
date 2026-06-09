{
  description = "toolbox — Rust workspace built with crane + fenix";

  # ---------------------------------------------------------------------------
  # Inputs
  # ---------------------------------------------------------------------------
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    crane.url = "github:ipetkov/crane";

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # ---------------------------------------------------------------------------
  # Outputs
  # ---------------------------------------------------------------------------
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      crane,
      fenix,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # -----------------------------------------------------------------------
        # Toolchain — pinned by ./rust-toolchain.toml
        #
        # The sha256 below corresponds to the channel/components requested in
        # rust-toolchain.toml. If you change the toolchain file, set this to
        # `pkgs.lib.fakeHash`, run `nix build`, and copy the correct hash out
        # of the resulting error.
        # -----------------------------------------------------------------------
        rustToolchain = fenix.packages.${system}.fromToolchainFile {
          file = ./rust-toolchain.toml;
          sha256 = "sha256-mvUGEOHYJpn3ikC5hckneuGixaC+yGrkMM/liDIDgoU=";
        };

        craneLib = (crane.mkLib pkgs).overrideToolchain rustToolchain;

        # -----------------------------------------------------------------------
        # Source filtering — keeps the build inputs small so cargoArtifacts is
        # reused across most edits.
        # -----------------------------------------------------------------------
        src = craneLib.cleanCargoSource ./.;

        commonArgs = {
          inherit src;
          strictDeps = true;

          # Add native runtime/build deps shared by all crates here. Per-crate
          # extras can be layered on at the `buildPackage` call below.
          buildInputs =
            with pkgs;
            [
            ]
            ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
              libiconv
            ];

          nativeBuildInputs = with pkgs; [
          ];
        };

        # Build only the workspace's dependency graph once; reused by every
        # downstream package and check below.
        cargoArtifacts = craneLib.buildDepsOnly (
          commonArgs
          // {
            pname = "toolbox-deps";
          }
        );

        # -----------------------------------------------------------------------
        # Per-crate builds
        #
        # `workspace` builds every member at once (handy for CI / `nix flake
        # check`). Per-crate derivations are exposed under packages.<name> and
        # build only their slice of the workspace via `cargoExtraArgs`.
        # -----------------------------------------------------------------------
        workspace = craneLib.buildPackage (
          commonArgs
          // {
            inherit cargoArtifacts;
            pname = "toolbox";
            doCheck = false;
          }
        );

        mkCrate =
          name:
          craneLib.buildPackage (
            commonArgs
            // {
              inherit cargoArtifacts;
              pname = name;
              cargoExtraArgs = "-p ${name}";
              doCheck = false;
            }
          );

        # Auto-discover app crates: every directory under ./apps with a
        # Cargo.toml becomes a package whose attribute name matches the
        # directory name. The crate's `[package].name` in its Cargo.toml
        # must match the directory name (cargo's -p uses package name).
        #
        # Library crates under ./libs are intentionally NOT enumerated here —
        # they are built transitively by cargo when an app depends on them,
        # and are still covered by the workspace-wide `checks` below.
        appsDir = ./apps;
        appNames = builtins.attrNames (
          pkgs.lib.filterAttrs (
            name: type:
            type == "directory" && builtins.pathExists (appsDir + "/${name}/Cargo.toml")
          ) (builtins.readDir appsDir)
        );

        # Per-crate Nix overrides applied on top of the auto-discovered set.
        # New apps that need similar treatment can follow the same
        # `optionalAttrs` pattern.
        appPackages =
          let
            base = pkgs.lib.genAttrs appNames mkCrate;
          in
          base
          // pkgs.lib.optionalAttrs (base ? tmux-session-manager) {
            tmux-session-manager = base.tmux-session-manager.overrideAttrs (old: {
              nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.makeWrapper ];
              postFixup = (old.postFixup or "") + ''
                wrapProgram $out/bin/tmux-session-manager \
                  --prefix PATH : ${
                    pkgs.lib.makeBinPath [
                      pkgs.bash
                      pkgs.tmux
                      pkgs.zoxide
                      pkgs.fzf
                      pkgs.gawk
                      pkgs.coreutils
                    ]
                  }
              '';
            });
          };
      in
      {
        # -----------------------------------------------------------------------
        # Checks — wired into `nix flake check` and surfaced in the dev shell.
        # -----------------------------------------------------------------------
        checks = {
          inherit workspace;

          workspace-clippy = craneLib.cargoClippy (
            commonArgs
            // {
              inherit cargoArtifacts;
              cargoClippyExtraArgs = "--all-targets -- --deny warnings";
            }
          );

          workspace-fmt = craneLib.cargoFmt {
            inherit src;
          };

          workspace-test = craneLib.cargoTest (
            commonArgs
            // {
              inherit cargoArtifacts;
            }
          );
        };

        # -----------------------------------------------------------------------
        # Packages
        #
        # Per-crate packages are auto-discovered. `workspace` builds the entire
        # workspace at once and `default` aliases it. Downstream consumers that
        # want to install every crate (e.g. pde.nix via `attrValues`) should
        # filter out `default` and `workspace` to avoid bin/ collisions.
        # -----------------------------------------------------------------------
        packages = appPackages // {
          default = workspace;
          inherit workspace;
        };

        # -----------------------------------------------------------------------
        # Apps — `nix run` entry points, one per crate
        # -----------------------------------------------------------------------
        apps = pkgs.lib.mapAttrs (_: drv: flake-utils.lib.mkApp { inherit drv; }) appPackages;

        # -----------------------------------------------------------------------
        # Dev shell
        # -----------------------------------------------------------------------
        devShells.default = craneLib.devShell {
          checks = self.checks.${system};

          packages = with pkgs; [
            rust-analyzer
            cargo-watch
            cargo-edit
          ];
        };

        formatter = pkgs.nixfmt;
      }
    );
}
