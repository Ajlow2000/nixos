{
    description = "Home Manager configuration of ajlow";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        nix-index-database.url = "github:Mic92/nix-index-database";
        nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        nix-citizen.url = "github:LovingMelody/nix-citizen";
        nix-gaming.url = "github:fufexan/nix-gaming";
        nix-citizen.inputs.nix-gaming.follows = "nix-gaming";

        toolbox = {
            url = "github:Ajlow2000/toolbox";
            flake = true;
        };
    };

    outputs = { nixpkgs, home-manager, nix-index-database, nix-citizen, ... }@inputs:
        let
        system = "x86_64-linux";
        pkgs = nixpkgs.legacyPackages.${system};
        in {
	        nixosConfigurations = {
	            hal9000 = nixpkgs.lib.nixosSystem {
                    specialArgs = { inherit system; };
	                modules = [ 
	                    ./system/hosts/hal9000.nix 
                        nix-citizen.nixosModules.StarCitizen
	                ];
		        };
	            multivac = nixpkgs.lib.nixosSystem {
                    specialArgs = { inherit system; };
	                modules = [ 
	                    ./system/hosts/multivac.nix 
	                ];
		        };
	            microvac = nixpkgs.lib.nixosSystem {
                    specialArgs = { inherit system; };
	                modules = [ 
	                    ./system/hosts/microvac.nix 
	                ];
		        };
	        };
            homeConfigurations = {
                ajlow = home-manager.lib.homeManagerConfiguration {
                    inherit pkgs;
                    modules = [ 
                        ./userspace/users/ajlow.nix 
                        nix-index-database.hmModules.nix-index
                    ];
                    extraSpecialArgs = {
                        inherit inputs;
                        inherit system;
                    };
                };
            };
            devShells.${system}.default = pkgs.mkShell {
                packages = with pkgs; [
                    nil
                ];
            };
        };
}
