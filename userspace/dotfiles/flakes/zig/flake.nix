{
  inputs = {
    nixpkgs = {
      type = "github";
      owner = "nixos";
      repo = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgsFor = system: nixpkgs.legacyPackages.${system};

      # Parse pname and version from build.zig
      buildZigContent = builtins.readFile ./build.zig;
      pnameMatch = builtins.match ".*const pname = \"([^\"]*)\";.*" buildZigContent;
      versionMatch = builtins.match ".*const version = \"([^\"]*)\";.*" buildZigContent;
      pname = if pnameMatch != null then builtins.head pnameMatch else "dsa";
      version = if versionMatch != null then builtins.head versionMatch else "0.0.0";
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.stdenv.mkDerivation {
            inherit pname version;
            src = ./.;

            nativeBuildInputs = with pkgs; [
              zig
            ];

            buildPhase = ''
              runHook preBuild
              export ZIG_GLOBAL_CACHE_DIR=$TMPDIR/zig-cache
              zig build -Doptimize=ReleaseSafe
              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall
              mkdir -p $out/bin
              cp zig-out/bin/${pname} $out/bin/${pname}
              runHook postInstall
            '';

            meta = with pkgs.lib; {
              description = "zig app";
              license = licenses.gpl3;
              platforms = platforms.all;
            };
          };
        }
      );

      checks = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          tests = pkgs.stdenv.mkDerivation {
            inherit pname version;
            src = ./.;

            nativeBuildInputs = with pkgs; [
              zig
            ];

            buildPhase = ''
              runHook preBuild
              export ZIG_GLOBAL_CACHE_DIR=$TMPDIR/zig-cache
              zig build test
              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall
              mkdir -p $out
              echo "Tests passed" > $out/test-results
              runHook postInstall
            '';
          };
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              nixpkgs-fmt
              zig
              zls
            ];

            shellHook = ''
              echo "Zig dev shell: (zig $(zig version))"
              echo "Available commands:"
              echo "  zig build        - Build the project"
              echo "  zig build run    - Build and run"
              echo "  zig build test   - Run tests"
            '';
          };
        }
      );

      devShell = forAllSystems (system: self.devShells.${system}.default);
    };
}
