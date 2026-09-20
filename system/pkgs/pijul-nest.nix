{
  fetchpijul,
  rustPlatform,
  pkg-config,
  openssl,
  libsodium,
  protobuf,
  clangStdenv,
  stdenv,
  nodejs,
  pnpm,
  fetchPnpmDeps,
  pnpmConfigHook,
  gnused,
  brotli,
  gzip,
  lib,
  ...
}:

let
  src = fetchpijul {
    url = "https://nest.pijul.com/pijul/nest";
    state = "";
    hash = "sha256-tivXZn5O5pJfjzvnYAa88z40jhVXj8NMTHwA3UBaSvQ=";
  };

  # Both nest and nest-rank are in the workspace; build them together to avoid
  # compiling all shared dependencies twice.
  bins = rustPlatform.buildRustPackage {
    pname = "pijul-nest";
    version = "unstable";
    inherit src;

    cargoLock.lockFile = "${src}/Cargo.lock";

    nativeBuildInputs = [ pkg-config protobuf ];
    buildInputs = [ openssl libsodium ];

    cargoBuildFlags = [ "--bins" ];

    # PROTOC is needed for etcd-client when compiling with --features jobs.
    # Set it unconditionally so adding the feature later doesn't require a hash bump.
    PROTOC = "${protobuf}/bin/protoc";

    doCheck = false;
  };

  migrations = stdenv.mkDerivation {
    name = "nest-diesel-migrations";
    inherit src;
    dontBuild = true;
    installPhase = ''
      mkdir -p "$out"
      mkdir -p $out/api/src
      cp diesel.toml "$out/"
      cp api/src/db.rs "$out/api/src"
      cp -R migrations "$out/"
    '';
  };

  pnpmHash = "sha256-7kQMyd7eDZgZN87y0u2OlceCe6bROjhQje2RsN6QWGc=";

  ui = clangStdenv.mkDerivation (finalAttrs: {
    pname = "pijul-nest-ui";
    version = "0.0.1";
    inherit src;

    # pnpm-workspace.yaml sets a virtualStoreDir outside the tree to avoid
    # copying ~650M of node_modules into the nix sandbox.  That path isn't
    # writable in the sandbox, so we strip the override before every pnpm run.
    prePnpmInstall = "sed -i '/virtualStoreDir/d' pnpm-workspace.yaml";

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs) pname version src prePnpmInstall;
      fetcherVersion = 4;
      hash = pnpmHash;
    };

    nativeBuildInputs = [ nodejs pnpm pnpmConfigHook gnused brotli gzip ];

    preConfigure = "rm -Rf node_modules site/node_modules ui/node_modules";

    buildPhase = ''
      cd ui
      pnpm run build
      cd ..
    '';

    installPhase = ''
      cp -r ui/build "$out"
      LANG=en_US date -u "+%s" > "$out/last_modified"
      find "$out/client/_app" -type f \( \
        -name "*.js" -o -name "*.css" -o -name "*.html" -o -name "*.svg" \
      \) | while IFS= read -r f; do
        rm -f "$f.gz" "$f.br"
        gzip  --best --keep "$f"
        brotli --best --keep "$f"
      done
    '';
  });

in {
  inherit bins ui migrations;
}
