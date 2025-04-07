{
    inputs = {
        nixpkgs.url = "nixpkgs";
        flake-utils.url = "github:numtide/flake-utils";
    };
    outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
        let 
            pkgs = nixpkgs.legacyPackages.${system}; 

            buildDependencies = with pkgs; [
                gnumake
                glib
                python3
            ] ++ lib.optionals stdenv.hostPlatform.isLinux [
                libbsd
            ];

            runtimeDependencies = with pkgs; [
            ];

            developerTooling = with pkgs; [
                nil             # Nix LSP
                marksman        # MD LSP
            ];

            envVars = ''
            '';
        in { 
            devShells.default = pkgs.mkShell {
              packages = buildDependencies ++ runtimeDependencies ++ developerTooling;
              shellHook = envVars;
              SRAM_BAMBAM_ROOT = "/home/ajlow/repos/sram_bambam";
          };
        }
    );
}

