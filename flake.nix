{
    description = "Home Manager configuration of ajlow";

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
    };

    outputs = { nixpkgs, home-manager, nix-index-database, ... }@inputs:
        let
        system = "x86_64-linux";
        pkgs = nixpkgs.legacyPackages.${system};
        in {
	    nixosConfigurations = {
	        hal9000 = nixpkgs.lib.nixosSystem {
                specialArgs = { inherit system; };
	            modules = [ 
	                ./hosts/hal9000/configuration.nix 
	            ];
		    };
	        multivac = nixpkgs.lib.nixosSystem {
                specialArgs = { inherit system; };
	            modules = [ 
	                ./hosts/multivac/configuration.nix 
	            ];
		    };
	    };
            homeConfigurations = {
                ajlow = home-manager.lib.homeManagerConfiguration {
                    inherit pkgs;
                    modules = [ 
                        ./users/ajlow.nix 
                        nix-index-database.hmModules.nix-index
                    ];
                    extraSpecialArgs = {
                        inherit inputs;
                        inherit system;
                    };
                };
            };
        };
}
