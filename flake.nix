{
  description = "My NixOS and Home Manager configurations";

  # ---------------------------------------------------------------------------
  # Inputs
  # ---------------------------------------------------------------------------
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    toolbox = {
      url = "github:Ajlow2000/toolbox";
      flake = true;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sentinelone = {
      url = "github:devusb/sentinelone-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-citizen = {
      url = "github:LovingMelody/nix-citizen";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixcraft = {
      url = "github:loystonpais/nixcraft";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-binary-ninja = {
      url = "github:jchv/nix-binary-ninja";
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
      nixpkgs-stable,
      home-manager,
      nix-index-database,
      sentinelone,
      neovim-nightly-overlay,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      # -----------------------------------------------------------------------
      # NixOS Configurations
      # Auto-discovered from ./system/hosts/*/default.nix
      # -----------------------------------------------------------------------
      nixosConfigurations =
        let
          hostsDir = ./system/hosts;
          hostNames = builtins.attrNames (
            nixpkgs.lib.filterAttrs (
              name: type: type == "directory" && builtins.pathExists (hostsDir + "/${name}/default.nix")
            ) (builtins.readDir hostsDir)
          );
        in
        builtins.listToAttrs (
          map (name: {
            inherit name;
            value = nixpkgs.lib.nixosSystem {
              specialArgs = {
                inherit system inputs;
                keys = import ./keys.nix;
              };
              modules = [ (hostsDir + "/${name}") ];
            };
          }) hostNames
        );

      # -----------------------------------------------------------------------
      # Packages & Apps
      # Exposes the DO base image and per-host VM builds
      # -----------------------------------------------------------------------
      packages.${system} = {
        do-base-image = self.nixosConfigurations.do-base-image.config.system.build.digitalOceanImage;
      }
      // nixpkgs.lib.mapAttrs' (
        name: cfg: nixpkgs.lib.nameValuePair "vm-${name}" cfg.config.system.build.vm
      ) self.nixosConfigurations;

      apps.${system} = nixpkgs.lib.mapAttrs' (
        name: cfg:
        nixpkgs.lib.nameValuePair "vm-${name}" {
          type = "app";
          program = "${cfg.config.system.build.vm}/bin/run-${name}-vm";
        }
      ) self.nixosConfigurations;

      # -----------------------------------------------------------------------
      # Home Manager Configurations
      # Auto-discovered from ./userspace/users/*.nix
      # Produces both bare "<user>" (x86_64-linux default) and "<user>@<system>" entries
      # -----------------------------------------------------------------------
      homeConfigurations =
        let
          usersDir = ./userspace/users;
          userNames = map (name: nixpkgs.lib.removeSuffix ".nix" name) (
            builtins.attrNames (
              nixpkgs.lib.filterAttrs (name: type: type == "regular" && nixpkgs.lib.hasSuffix ".nix" name) (
                builtins.readDir usersDir
              )
            )
          );
          mkHomeConfig =
            system: user:
            home-manager.lib.homeManagerConfiguration {
              pkgs = nixpkgs.legacyPackages.${system};
              modules = [
                (usersDir + "/${user}.nix")
                nix-index-database.homeModules.nix-index
              ];
              extraSpecialArgs = {
                inherit inputs system;
                keys = import ./keys.nix;
              };
            };
        in
        nixpkgs.lib.foldl'
          (
            acc: system:
            acc
            // (builtins.listToAttrs (
              map (user: {
                name = "${user}@${system}";
                value = mkHomeConfig system user;
              }) userNames
            ))
          )
          (builtins.listToAttrs (
            map (user: {
              name = user;
              value = mkHomeConfig "x86_64-linux" user;
            }) userNames
          ))
          supportedSystems;

      # -----------------------------------------------------------------------
      # Dev Shell
      # -----------------------------------------------------------------------
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            buildInputs =
              (with pkgs; [
                nil
                just
                neovim
                git
                coreutils
                marksman
                nixfmt
              ])
              ++ [
                home-manager.packages.${system}.default
              ];
          };
        }
      );
    };
}
