{
  description = "Go application flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgsFor = system: nixpkgs.legacyPackages.${system};
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.buildGoModule {
            pname = "go-app";
            version = "0.1.0";
            src = ./.;
            vendorHash = null;
            
            meta = with pkgs.lib; {
              description = "Go application";
              license = licenses.mit;
              maintainers = [ ];
            };
          };
        });

      checks = forAllSystems (system:
        let
          pkgs = pkgsFor system;
        in
        {
          test = pkgs.stdenv.mkDerivation {
            name = "go-test";
            src = ./.;
            buildInputs = [ pkgs.go ];
            buildPhase = ''
              export HOME=$TMPDIR
              go test ./...
            '';
            installPhase = ''
              touch $out
            '';
          };
        });

      devShells = forAllSystems (system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              go
              gopls
              gotools
              go-tools
            ];
            
            shellHook = ''
              echo "Go development environment: $(go version)"
            '';
          };
        });
    };
}
