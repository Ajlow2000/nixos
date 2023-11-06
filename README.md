<div align="center">
  <a href="https://github.com/Ajlow2000/nixos">
    <img src="images/nix-snowflake.svg" alt="Logo" width="80" height="80">
  </a>

  <h1 align="center">NixOS</h1>

  <p align="center">
    My NixOS Config deployed as a flake.
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
[NixOS Wiki](https://nixos.wiki/wiki/NixOS_Installation_Guide).

I deploy my Nixos configuration as a flake which needs be enabled
via the option```nix.settings.experimental-features = [ "nix-command" "flakes" ];```.
Typically this requires manually adding it to the preexisting config
found at `/etc/nixos/configuration.nix` and then rebuilding with
```sudo nixos-rebuild switch --flake /path/to/flake/#flake_profile```

[Nix Flakes documentation](https://nixos.wiki/wiki/Flakes) if
needed.

### Rebuilding and Updating
To rebuild nixos, run the command 
```sudo nixos-rebuild switch --flake /path/to/flake/#flake_profile```
where `flake_profile` is whatever gets set in your flake.nix.  
I define the following alias for convenience in my [home manager](https://github.com/Ajlow2000/home-manager):
```
home.shellAliases = {
    nrs = "sudo nixos-rebuild switch --flake $XDG_CONFIG_HOME/nixos/#$NIXOS_CONFIG_PROFILE";
}
```

One advantage of nixos as a flake is pinned dependencies for reproducibility (flake.lock).
In practice, this means the nix channel I follow gets pinned and
thus all packages I download and install are the same across
all machines I use. To upgrade all system packages, I run the
command ```nix flake update```, rebuild nixos, and then 
commit my new lockfile.
