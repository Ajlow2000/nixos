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
