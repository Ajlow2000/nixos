{ stdenv, fetchurl }:
let
  version = "0.1.0";
in
stdenv.mkDerivation {
  pname = "glance-agent";
  inherit version;

  src = fetchurl {
    url = "https://github.com/glanceapp/agent/releases/download/v${version}/agent-linux-amd64.tar.gz";
    hash = "sha256-aqFH3/1mKXS+eEgz514/LdgUGwT95mp6MdFpRtDmVi4=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cd $(mktemp -d)
    tar xzf $src
    install -m755 agent $out/bin/glance-agent
    runHook postInstall
  '';
}
