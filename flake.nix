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
    };

    outputs = { nixpkgs, home-manager, nix-index-database, sentinelone, ... }@inputs:
        let
        system = "x86_64-linux";
        pkgs = nixpkgs.legacyPackages.${system};
        in {
	        nixosConfigurations = {
	            hal9000 = nixpkgs.lib.nixosSystem {
                    specialArgs = { inherit system; };
	                modules = [ 
	                    ./system/hosts/hal9000.nix 
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
	            marvin = nixpkgs.lib.nixosSystem {
                    specialArgs = { inherit system; };
	                modules = [ 
                        inputs.sentinelone.nixosModules.sentinelone
	                    ./system/hosts/marvin.nix 
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
            devShell.${system} = pkgs.mkShell {
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
