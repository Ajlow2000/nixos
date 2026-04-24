{
  config,
  lib,
  pkgs,
  inputs,
  system,
  ...
}:
let
  cfg = config.gui_utilities;
  # BN updates the zip at the same URL without bumping the version; override hash until upstream fixes it
  binary-ninja-free =
    (inputs.nix-binary-ninja.packages.${system}.binary-ninja-free-wayland).overrideAttrs
      (old: {
        src = pkgs.fetchurl {
          url = "https://cdn.binary.ninja/installers/binaryninja_free_linux.zip";
          hash = "sha256-knicC9Ph91saA9gOdOt+qNOpXhn3kVVXd0oK1AJnSSY=";
        };
      });
in
{
  options = {
    gui_utilities.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      with pkgs;
      (
        [
        ]
        ++ lib.optionals stdenv.isLinux [
          # Linux-only GUI apps
          zoom-us
          firefox
          inkscape
          wireshark
          discord
          spotify
          element-desktop
          anki
          signal-desktop
          ghidra
          binary-ninja-free
          gimp
          krita
          zathura
          microsoft-edge
          evince
          teams-for-linux
          chromium
          godot
        ]
      );
  };
}
