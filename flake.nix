{
    description = "My NixOS and Home Manager configurations";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";
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
        };
        nixos-cosmic = {
            url = "github:lilyinstarlight/nixos-cosmic";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        zen-browser = {
            url = "github:0xc000022070/zen-browser-flake";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = { nixpkgs, nixpkgs-stable, home-manager, ... }@inputs:
        let
        system = "x86_64-linux";
        pkgs = nixpkgs.legacyPackages.${system};
        in {
	        nixosConfigurations = {
	         #    hal9000 = nixpkgs.lib.nixosSystem {
             #        specialArgs = { inherit system; };
	         #        modules = [ 
	         #            ./nixos/hosts/hal9000.nix 
	         #        ];
		     #    };
	         #    multivac = nixpkgs.lib.nixosSystem {
             #        specialArgs = { inherit system; };
	         #        modules = [ 
	         #            ./nixos/hosts/multivac.nix 
	         #        ];
		     #   };
	            microvac = nixpkgs.lib.nixosSystem {
                    specialArgs = { inherit system; };
	                modules = [ 
                        {
                            nix.settings = {
                                substituters = [ "https://cosmic.cachix.org/" ];
                                trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
                            };
                        }
                        inputs.nixos-cosmic.nixosModules.default
	                    ./nixos/hosts/microvac.nix 
	                ];
		        };
	            marvin = nixpkgs.lib.nixosSystem {
                    specialArgs = { inherit system; };
	                modules = [ 
                        {
                            nix.settings = {
                                substituters = [ "https://cosmic.cachix.org/" ];
                                trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
                            };
                        }
                        inputs.nixos-cosmic.nixosModules.default
	                    ./nixos/hosts/marvin.nix 
	                ];
		        };
	        };
            homeConfigurations = {
                ajlow = home-manager.lib.homeManagerConfiguration {
                    inherit pkgs;
                    modules = [ 
                        ./userspace/users/ajlow.nix 
                        inputs.nix-index-database.hmModules.nix-index
                    ];
                    extraSpecialArgs = {
                        inherit inputs;
                        inherit system;
                    };
                };
            };
            devShells.${system}.default = pkgs.mkShell {
                buildInputs = with pkgs; [
                    nil
                    just
                    neovim
                    git
                    coreutils
                    marksman
                ];
            };
        };
}
