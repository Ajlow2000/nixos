<div align="center">
  <a href="https://github.com/Ajlow2000/nixos">
    <img src="images/nix-snowflake.svg" alt="Logo" width="80" height="80">
  </a>

  <h1 align="center">NixOS and Home Manager</h1>

  <p align="center">
    My NixOS and Home Manager Configurations deployed as a flake.
    <br />
    <a href="https://nixos.org/">Homepage</a>
    ·
    <a href="https://discourse.nixos.org/">Forums</a>
    ·
    <a href="https://search.nixos.org/packages">Nixpkgs</a>
  </p>
</div>

## Repository Structure

This repository uses a modular, role-based configuration system:

### System Configuration (`/system`)

```
system/
├── profiles/          # Role-based system profiles
│   ├── base.nix       # Base system (Nix settings, core packages)
│   ├── desktop.nix    # Desktop systems
│   └── laptop.nix     # Laptop systems (desktop + power management)
├── modules/           # Modular system components
│   ├── desktop/       # Desktop environments (GNOME, COSMIC)
│   ├── services/      # System services (audio, docker, gaming, etc.)
│   ├── hardware/      # Hardware support (tablet, power)
│   ├── work/          # Work-specific (SentinelOne, SRAM udev rules)
│   └── localization/  # i18n modules
└── hosts/            # Host-specific configurations
    ├── hal9000/      # Each host has its own directory
    ├── marvin/
    └── ...
```

### User Configuration (`/userspace`)

```
userspace/
├── modules/          # User-level modules
├── users/           # User-specific configs (ajlow, alowry)
└── dotfiles/        # Configuration files
```

### Module System

Modules use namespaced options for clarity:
- System profiles: `profiles.system.{base,desktop,laptop}`
- System modules: `modules.{desktop,services,hardware,work}.{name}`
- Example: `modules.services.gaming.enable = true;`

### Adding a New Host

1. Create directory: `system/hosts/newhostname/`
2. Add `hardware.nix` (from nixos-generate-config)
3. Create `default.nix` importing appropriate profile:
   ```nix
   { pkgs, lib, ... }: {
     imports = [
       ./hardware.nix
       ../../profiles/desktop.nix  # or laptop.nix
       # Add desktop environment and services
     ];

     profiles.system.desktop.enable = true;
     # ... host-specific config
   }
   ```
4. Add to `flake.nix` nixosConfigurations

## Usage

### Installation
Official installation instructions can be found in the 
[NixOS Wiki](https://nixos.wiki/wiki/Home_Manager) or the
[Home Manager community docs](https://nix-community.github.io/home-manager/).


I deploy my HM configuration as a flake which needs be enabled.
For standalone personal computers, I enable this via a nixos
option `nix.settings.experimental-features = [ "nix-command" "flakes" ];`.
If running Home Manager on top of another distro, I enable this
via a nix config file:
```
# ~/.config/nix/nix.conf
experimental-features = nix-command flakes 
```
[Nix Flakes documentation](https://nixos.wiki/wiki/Flakes) if
needed.

### Post garbage collection fix for win11 vm
https://crescentro.se/posts/windows-vm-nixos/
`nix eval nixpkgs#qemu.outPath`
`virsh edit win11`

### WSL
[https://github.com/nix-community/NixOS-WSL]
