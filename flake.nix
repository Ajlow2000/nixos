{
  description = "My NixOS Configuration Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in
  {
    nixosConfigurations = {
      workstation = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit system; };
	modules = [ 
	  ./workstation/configuration.nix 
	];
      };
    };
  };
}
