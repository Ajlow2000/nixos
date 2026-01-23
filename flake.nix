{
    description = "My NixOS and Home Manager configurations";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nix-index-database.url = "github:Mic92/nix-index-database";
        nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
        toolbox = {
            url = "github:Ajlow2000/toolbox";
            flake = true;
        };
        sentinelone.url = "github:devusb/sentinelone-nix";
        neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
        hytale-nix.url = "github:andreashgk/hytale-nix";
    };

    outputs = { nixpkgs, home-manager, nix-index-database, sentinelone, neovim-nightly-overlay, ... }@inputs:
        let
        system = "x86_64-linux";
        pkgs = nixpkgs.legacyPackages.${system};

        # Support for devShell on multiple platforms
        supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
        forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
        in {
	        nixosConfigurations = {
		    mindgame = nixpkgs.lib.nixosSystem {
                    specialArgs = { inherit system; };
                        modules = [
                            ./system/hosts/mindgame
                        ];
                        };
	            hal9000 = nixpkgs.lib.nixosSystem {
                    specialArgs = { inherit system; };
	                modules = [
	                    ./system/hosts/hal9000
	                ];
		        };
	            multivac = nixpkgs.lib.nixosSystem {
                    specialArgs = { inherit system; };
	                modules = [
	                    ./system/hosts/multivac
	                ];
		        };
	            microvac = nixpkgs.lib.nixosSystem {
                    specialArgs = { inherit system; };
	                modules = [
	                    ./system/hosts/microvac
	                ];
		        };
	            marvin = nixpkgs.lib.nixosSystem {
                    specialArgs = { inherit system; };
	                modules = [
                        inputs.sentinelone.nixosModules.sentinelone
	                    ./system/hosts/marvin
	                ];
		        };
	        };
            homeConfigurations =
                let
                    mkHomeConfig = system: user: home-manager.lib.homeManagerConfiguration {
                        pkgs = nixpkgs.legacyPackages.${system};
                        modules = [
                            ./userspace/users/${user}.nix
                            nix-index-database.hmModules.nix-index
                        ];
                        extraSpecialArgs = {
                            inherit inputs system;
                        };
                    };
                in
                    nixpkgs.lib.foldl' (acc: system:
                        acc // {
                            "ajlow@${system}" = mkHomeConfig system "ajlow";
                            "alowry@${system}" = mkHomeConfig system "alowry";
                        }
                    ) {
                        # Default configs use x86_64-linux for backwards compatibility
                        ajlow = mkHomeConfig "x86_64-linux" "ajlow";
                        alowry = mkHomeConfig "x86_64-linux" "alowry";
                    } supportedSystems;
            devShells = forAllSystems (system:
                let
                    pkgs = nixpkgs.legacyPackages.${system};
                in {
                    default = pkgs.mkShell {
                        buildInputs = (with pkgs; [
                            nil
                            just
                            neovim
                            git
                            coreutils
                            marksman
                        ]) ++ [
                            home-manager.packages.${system}.default
                        ];
                    };
                }
            );
        };
}
