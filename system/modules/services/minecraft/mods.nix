# Shared Modrinth mod definitions.
# Usage in a server module:
#   let mods = import ./mods.nix { inherit pkgs; }; in ...
#   symlinks = { "mods/foo.jar" = mods.foo; };
{ pkgs }:
{
  # --- dependencies ---
  fabricApi = pkgs.fetchurl {
    url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/i5tSkVBH/fabric-api-0.141.3%2B1.21.11.jar";
    hash = "sha512-wgwBfiPW0ndGkNDdd0zshMFr+sVGHaLZNFoc2V7uSVsZVDM8Qh49HGYYYoTSSkM/awzO2AIfYuC/phfSOE0EcQ==";
  };

  pneumonoCore = pkgs.fetchurl {
    url = "https://cdn.modrinth.com/data/ZLKQjA7t/versions/jroJhBqO/pneumonocore-1.3.1%2B1.21.11%2BA.jar";
    hash = "sha512-8lxEo201S3pZJUi8LgWZ884mR8LtceL1ZydQSOESpZfMVmJLuXqhrbeE3byt8Kl6b+Z5Q2woaxETHJSt/JHuZA==";
  };

  balm = pkgs.fetchurl {
    url = "https://cdn.modrinth.com/data/MBAkmtvl/versions/wk8IL07y/balm-fabric-1.21.11-21.11.9.jar";
    hash = "sha512-QsiUz02NX4nRgGqjl/k52M514HnODCH1pHIAI+tkyGFYXis9GrUORIez6IYSsD4x4J9wkVCTuikdgDSfzQ1W1Q==";
  };

  # --- mods ---
  gravestones = pkgs.fetchurl {
    url = "https://cdn.modrinth.com/data/Heh3BbSv/versions/PEoDCnPk/gravestones-1.3.0%2B1.21.11%2BA.jar";
    hash = "sha512-xHojTsyRde/u8duWyU7gtUOIoDkuqw+WX/rusTMQK/G56ttS1TASNTvKuSrW5jSkT/Ufl/bkdO5rPj7UDqk8Xg==";
  };

  waystones = pkgs.fetchurl {
    url = "https://cdn.modrinth.com/data/LOpKHB2A/versions/MydMW2TT/waystones-fabric-1.21.11-21.11.9.jar";
    hash = "sha512-BHBJ2Ml8Ks3zPJq6qm+i2grExX+BpJYaJcPVit3Grfzcx5Onv2yhs3kxKs5p9IsNfDg7Xx1DCZGReGMrRt7ZeA==";
  };
}
