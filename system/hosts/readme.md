# Hosts

Each subdirectory here is a machine-specific NixOS configuration. The flake
picks them up automatically — no manual `flake.nix` edits required.

## Autodiscovery

`flake.nix` scans this directory at eval time:

1. Calls `builtins.readDir ./system/hosts` to list all entries.
2. Filters to entries that are directories **and** contain a `default.nix`.
3. Creates a `nixosConfiguration` for each matching directory automatically.

Relevant snippet from `flake.nix`:

```nix
nixosConfigurations =
  let
    hostsDir = ./system/hosts;
    hostNames = builtins.attrNames (
      nixpkgs.lib.filterAttrs (
        name: type: type == "directory" && builtins.pathExists (hostsDir + "/${name}/default.nix")
      ) (builtins.readDir hostsDir)
    );
  in
  builtins.listToAttrs (
    map (name: {
      inherit name;
      value = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit system inputs;
          keys = import ./keys.nix;
        };
        modules = [
          inputs.disko.nixosModules.disko
          (hostsDir + "/${name}")
        ];
      };
    }) hostNames
  );
```

## Adding a New Host

1. **Create the host directory**
   ```
   mkdir system/hosts/<hostname>
   ```

2. **Generate hardware config** — on the target machine run:
   ```
   nixos-generate-config --show-hardware-config > system/hosts/<hostname>/hardware.nix
   ```

3. *(Optional)* **Create `disko.nix`** for declarative disk partitioning.

4. **Create `default.nix`** — import `hardware.nix`, a profile, and any modules;
   set `networking.hostName` and `system.stateVersion`:
   ```nix
   { pkgs, lib, ... }: {
     imports = [
       ./hardware.nix
       ../../profiles/desktop.nix  # base | desktop | laptop
     ];

     networking.hostName = "<hostname>";
     system.stateVersion = "25.05";

     # host-specific options here
   }
   ```

5. *(Optional)* **Create `readme.md`** with hardware specs and notes.
   Use `template-readme.md` as a starting point.

6. **Deploy** — the flake autodiscovery picks up the new host automatically:
   ```
   nixos-rebuild switch --flake .#<hostname>
   ```

## Directory Layout

```
system/hosts/<hostname>/
├── default.nix      # required — triggers autodiscovery
├── hardware.nix     # from nixos-generate-config
├── disko.nix        # optional — declarative disk layout
└── readme.md        # optional — hardware specs & notes
```
