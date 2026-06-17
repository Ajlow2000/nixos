# Empire at War Linux Mod Tool (EAW_LMT)
#
# Packs loose Empire at War mod files into .meg archives to fix Proton stuttering
# on Linux. The tool is a folder of bash scripts plus a bundled Windows meg-packer
# (yvaw-build.exe, run via Wine) that must be deployed *next to a mod's Data folder*
# and run in place.
#
# This module installs two commands:
#   - eaw-lmt-setup-wine : one-time, initializes ~/.wine and installs a pinned
#                          wine-mono (offline, reproducible). yvaw-build.exe is a
#                          .NET/Mono app, so Mono is required.
#   - eaw-lmt-deploy     : copies a writable copy of the tool next to a mod's Data
#                          folder so it can be run in place.
#
# This is entirely independent of how the *game* runs. The game still launches
# through Steam Proton untouched; Wine here is only used to run the small mod-packer
# exe once at build time. Runtime deps:
#   - wine: pinned here (matches the system wine in system/profiles/desktop.nix)
#   - rsync: installed via userspace/modules/pde.nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.eawModTool;

  # Same wine as the system (system/profiles/desktop.nix). yvaw-build.exe needs Mono,
  # which this wine (11.0) expects at version 10.4.1 (see appwiz.cpl). If nixpkgs bumps
  # wine to a version that wants a different Mono, bump wine-mono-msi below to match.
  wine = pkgs.wineWow64Packages.stable;

  wine-mono-msi = pkgs.fetchurl {
    url = "https://dl.winehq.org/wine/wine-mono/10.4.1/wine-mono-10.4.1-x86.msi";
    hash = "sha256-Bx9LKIfhyXoR15H/PWW+lCnu1t7EwnCIiL/VRro1jiM=";
  };

  # One-time Wine prefix + Mono setup. Idempotent: no-op if Mono is already present.
  eaw-lmt-setup-wine = pkgs.writeShellApplication {
    name = "eaw-lmt-setup-wine";
    runtimeInputs = [
      wine
      pkgs.coreutils
    ];
    text = ''
      export WINEPREFIX="''${WINEPREFIX:-$HOME/.wine}"
      echo "Using WINEPREFIX=$WINEPREFIX"
      if [ -d "$WINEPREFIX/drive_c/windows/mono" ]; then
        echo "Mono already present at $WINEPREFIX/drive_c/windows/mono — nothing to do."
        exit 0
      fi
      echo "Initializing Wine prefix (suppressing Mono/Gecko download prompts)..."
      WINEDLLOVERRIDES="mscoree,mshtml=" wineboot --init
      wineserver --wait || true
      echo "Installing pinned wine-mono 10.4.1..."
      wine msiexec /i "${wine-mono-msi}"
      wineserver --wait || true
      if [ -d "$WINEPREFIX/drive_c/windows/mono" ]; then
        echo "Success: Mono installed at $WINEPREFIX/drive_c/windows/mono"
      else
        echo "ERROR: Mono dir not found after install; review output above." >&2
        exit 1
      fi
    '';
  };

  # Package the EAW_LMT folder into the Nix store (read-only).
  eaw-lmt = pkgs.stdenvNoCC.mkDerivation {
    pname = "eaw-linux-mod-tool";
    version = "0-unstable-2026-06-16";
    src = pkgs.fetchFromGitHub {
      owner = "Alexeyov";
      repo = "Empire-at-War-Linux-Mod-Tool";
      rev = "e30b7d189cebb24d3affc3031856f318f7205a4c";
      hash = "sha256-6shqhX2rSTv5Mj7gR+IyQ2SjM/uoUaokMjJw0KvAI6I=";
    };
    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/eaw-lmt
      cp -r EAW_LMT/. $out/share/eaw-lmt/
      chmod +x $out/share/eaw-lmt/*.sh || true
      runHook postInstall
    '';
    meta = with lib; {
      description = "Packs Empire at War mod files into .meg to fix Proton stutter on Linux";
      homepage = "https://github.com/Alexeyov/Empire-at-War-Linux-Mod-Tool";
      license = licenses.mit;
      platforms = platforms.linux;
    };
  };

  # Deploy command: copies a WRITABLE copy of EAW_LMT next to a mod's Data folder.
  eaw-lmt-deploy = pkgs.writeShellApplication {
    name = "eaw-lmt-deploy";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      target="''${1:-$PWD}"
      dest="$target/EAW_LMT"
      if [ ! -d "$target/Data" ] && [ ! -d "$target/DATA" ]; then
        echo "Warning: no Data folder found in '$target'." >&2
        echo "Run this in (or pass) the mod root that contains the Data folder." >&2
      fi
      mkdir -p "$dest"
      cp -rT "${eaw-lmt}/share/eaw-lmt" "$dest"
      chmod -R u+w "$dest"
      echo "Deployed EAW_LMT -> $dest"
      echo "Next:  cd \"$dest\" && bash EAWM_BUILD.sh"
    '';
  };
in
{
  options.eawModTool.enable = lib.mkEnableOption "Empire at War Linux Mod Tool";

  config = lib.mkIf cfg.enable {
    home.packages = [
      eaw-lmt-setup-wine
      eaw-lmt-deploy
    ];
  };
}
