{ stdenv, fetchurl, autoPatchelfHook, gcc }:
let
  version = "0.9.0";
  loreCli = fetchurl {
    url = "https://github.com/EpicGames/lore/releases/download/v${version}/lore-v${version}-x86_64-unknown-linux-gnu.tar.gz";
    hash = "sha256-BaGJBAb/QA0mXkPFiv702i/csjZCSDdm6zW7DUuQSlo=";
  };
  loreServer = fetchurl {
    url = "https://github.com/EpicGames/lore/releases/download/v${version}/loreserver-v${version}-x86_64-unknown-linux-gnu.tar.gz";
    hash = "sha256-0wMkzhD1SYp0nm3qZRANARA0dKU3PLXbDycIMclnodc=";
  };
in
stdenv.mkDerivation {
  pname = "lore";
  inherit version;

  dontUnpack = true;
  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ gcc.cc.lib ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin

    pushd $(mktemp -d)
    tar xzf ${loreCli}
    find . -maxdepth 2 -name 'lore' -type f -exec install -m755 {} $out/bin/lore \;
    popd

    pushd $(mktemp -d)
    tar xzf ${loreServer}
    find . -maxdepth 2 -name 'loreserver' -type f -exec install -m755 {} $out/bin/loreserver \;
    popd

    runHook postInstall
  '';
}
