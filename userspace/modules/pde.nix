{
  config,
  lib,
  pkgs,
  inputs,
  system,
  ...
}:
let
  inherit (inputs) toolbox;
  cfg = config.pde;

  blendr = pkgs.rustPlatform.buildRustPackage rec {
    pname = "blendr";
    version = "1.3.3";

    src = pkgs.fetchFromGitHub {
      owner = "dmtrKovalenko";
      repo = "blendr";
      rev = "v${version}";
      hash = "sha256-6QRI1MQnoppzlVfRV/bfqfTnBjC0/haFm52Ez9nltzw=";
    };

    cargoHash = "sha256-TMFE1I2ozY2Cu8S+CdeuGWK77JVpFSj229tKbTmC5rw=";

    nativeBuildInputs = with pkgs; [ pkg-config ];

    buildInputs = with pkgs; lib.optionals stdenv.isLinux [ dbus ];

    # time 0.3.22 doesn't compile with Rust >=1.80: Box<_> is ambiguous, Box<[_]> is not
    postPatch = ''
      chmod -R u+w ../blendr-${version}-vendor || true
      substituteInPlace \
        ../blendr-${version}-vendor/source-registry-0/time-0.3.22/src/format_description/parse/mod.rs \
        --replace-fail ".collect::<Result<Box<_>, _>>()?;" \
                       ".collect::<Result<Box<[_]>, _>>()?;"
    '';

    meta = with pkgs.lib; {
      description = "The hacker's BLE (bluetooth low energy) browser terminal app";
      homepage = "https://github.com/dmtrKovalenko/blendr";
      license = licenses.bsd3;
      mainProgram = "blendr";
    };
  };
in
{
  options = {
    pde.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    programs = {
      direnv = {
        enable = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;
      };
    };

    home.packages =
      with pkgs;
      (
        [
          ### PDE
          neovim
          (runCommand "nvim-nightly" { } ''
            mkdir -p $out/bin
            ln -s ${inputs.neovim-nightly-overlay.packages.${system}.default}/bin/nvim $out/bin/nvim-nightly
          '')
          tmux
          zellij
          neovim-remote
          zsh
          delta
          zoxide
          kitty
          hack-font
          lf
          xplr
          yazi
          gh
          nerd-fonts.hack
          nerd-fonts.fira-code
          nerd-fonts.meslo-lg

          jq
          gnumake
          bat
          git
          pijul
          fzf
          ripgrep
          gnugrep
          mercurial
          darcs
          subversion
          unixtools.xxd
          gum
          glow
          fd
          sd
          htop
          eza
          tealdeer
          gh-dash
          realvnc-vnc-viewer

          openssh
          zip
          unzip
          rsync
          gnupatch
          bzip2
          gnupg
          dig
          whois
          transmission_4
          binsider

          gdb
          bitwarden-cli
          hyperfine
          nmap
          tokei
          binwalk
          bandwhich
          atuin
          csvlens
          dua
          claude-code
          opencode
          ollama-vulkan
          bottom
          zls

          ### Global Language Support
          asm-lsp
          lua-language-server
          bash-language-server
          rust-analyzer
          rustc
          nil
          nh
          nix-output-monitor
          marksman
          gcc
          scc

          moreutils # only necessary to provide vipe until nix build of conventional-commit is working
        ]
        ++ lib.optionals stdenv.isLinux [
          # Linux-only utilities
          xclip
          util-linux
          lsb-release
          usbutils
          pciutils
          interception-tools
          ghostty
          rr
          arp-scan
          signal-cli
          syft
          grype
          blendr
          ventoy

          # Toolbox packages (currently Linux-only)
          toolbox.packages.${system}.print-path
          toolbox.packages.${system}.audit-dir
          #toolbox.packages.${system}.repo-manager
          #toolbox.packages.${system}.conventional-commit
          toolbox.packages.${system}.tmux-session-manager
          toolbox.packages.${system}.zellij-session-manager
        ]
      );

    home.file = {
      neovim = {
        recursive = true;
        source = ../dotfiles/nvim;
        target = "./.config/nvim";
      };
      kitty = {
        recursive = true;
        source = ../dotfiles/kitty;
        target = "./.config/kitty";
      };
      ghostty = {
        recursive = true;
        source = ../dotfiles/ghostty;
        target = "./.config/ghostty";
      };
      opencode = {
        recursive = true;
        source = ../dotfiles/opencode;
        target = "./.config/opencode";
      };
      atuin = {
        source = ../dotfiles/atuin;
        target = "./.config/atuin";
      };
      tmux = {
        source = ../dotfiles/tmux/tmux.conf;
        target = "./.tmux.conf";
      };
      zellij = {
        recursive = true;
        source = ../dotfiles/zellij;
        target = "./.config/zellij";
      };
      git = {
        recursive = true;
        source = ../dotfiles/git;
        target = "./.config/git";
      };
      zsh = {
        recursive = false;
        source = ../dotfiles/zsh/zshrc;
        target = "./.zshrc";
      };
      repo-manager = {
        recursive = true;
        source = ../dotfiles/repo-manager;
        target = "./.config/repo-manager";
      };
      rmpc = {
        recursive = true;
        source = ../dotfiles/rmpc;
        target = "./.config/rmpc";
      };
      scripts = {
        recursive = false;
        source = ../dotfiles/scripts;
        target = "./.local/bin";
      };
      gdb = {
        recursive = false;
        source = ../dotfiles/gdb/gdbinit;
        target = "./.gdbinit";
      };
      direnv-nom-wrap = {
        target = "./.config/direnv/lib/zz-nom-wrap.sh";
        text = ''
          # Route nix-direnv's print-dev-env through nix-output-monitor.
          # Sources after hm-nix-direnv.sh (alphabetical) so this override wins.
          _nix() {
            if [[ "$1" == "print-dev-env" ]]; then
              "''${_nix_direnv_nix}" --no-warn-dirty \
                --extra-experimental-features "nix-command flakes" \
                --log-format internal-json -v "$@" \
                2> >(${pkgs.nix-output-monitor}/bin/nom --json >&2)
            else
              "''${_nix_direnv_nix}" --no-warn-dirty \
                --extra-experimental-features "nix-command flakes" "$@"
            fi
          }
        '';
      };
    };

    xdg.desktopEntries = lib.mkIf pkgs.stdenv.isLinux {
      win11 = {
        name = "Windows11 VM";
        genericName = "VM";
        exec = "virt-manager --connect qemu:///system --show-domain-console win11";
        categories = [ "System" ];
      };
    };
  };
}
