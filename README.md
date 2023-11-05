<div align="center">
  <a href="https://github.com/Ajlow2000/home-manager">
    <img src="images/nix-snowflake.svg" alt="Logo" width="80" height="80">
  </a>

  <h1 align="center">Home Manager with Nix</h1>

  <p align="center">
    My Home Manager deployed as a flake.
    <br />
    <a href="https://github.com/nix-community/home-manager">Src</a>
    ·
    <a href="https://nix-community.github.io/home-manager/options.html">Options</a>
    ·
    <a href="https://search.nixos.org/packages">Nixpkgs</a>
  </p>
</div>

## Usage

### Installation
Official installation instructions can be found in the [Home
Manager community docs](https://nix-community.github.io/home-manager/) or the
[NixOS Wiki](https://nixos.wiki/wiki/Home_Manager).

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

### Rebuilding and Updating
To rebuild home manager, run the command `home-manager switch
--flake /path/to/flake/#<flake_profile>` where `flake_profile` is
whatever gets set in your flake.nix.  I define the following
alias for convenience:
```hms = "home-manager switch --flake $XDG_CONFIG_HOME/home-manager/#$USER";```

One advantage of home manager as a flake is pinned dependencies for reproducibility (flake.lock).
In practice, this means my nix channel I follow gets pinned and
thus all packages I download and install are the the same across
all machines I use. To upgrade all system packages, I run the
command ```nix flake update```, rebuild home manager, and then 
commit my new lockfile.

## Motivation 
This is a story about my journey that has led to nix/home-manager)
and not a salespitch about why one should use NixOS/Home Manager.


I started down the road of version controlled configuration when
learning vim back in college. As I began using more cli tools (as
well as writing my own), I began writing scripts to clone and
symlink my various configurations to where they should be. This
made my life easier, but it also shined a light on the other
aspects of my linux environment which I depend on and weren't
tracked in a VCS: user setup, environment variables, installed
packages, etc. 

My initial attempt at solving this issue was
writing idempotent/reentrant bash scripts. This proved to be
difficult to write in bash correctly (shock). As I started to
rewrite them in a more serious language, I learned about
[Ansible](https://www.ansible.com/) and followed 
[this guide](https://opensource.com/article/18/3/manage-workstation-ansible)
to get started.

Ansible worked well for the basics of what I was trying to
achieve, and I'm glad I spent some time building some familiarity
with the tool itself.  However, I didn't enjoy using it on a day
to day basis. It was slow to rebuild my system from a playbook
which discouraged making changes to my playbook before making the
change to my system the normal way (ie: if I needed a new
package, I would apt install it and then maybe go add it to my
playbook).  My playbooks would continuously fall out of date and
require large rewrites. Not to mention non-trivial changes that
required experimentation to get working first, and then more
experimentation get working in my playbook-- and don't get me
started on testing/validating my playbook.  At any rate, using
ansible introduced a ton of friction into my daily computing
habits, so I dropped it.

In it's place I reverted to using [yadm](https://yadm.io/) for
managing all my configurations, and a revival of my idempotent
scripts.  A simple, yet convenient set of tools to make me feel
comfy on a new linux installation. In general, yadm is a great
tool that I highly recommend using.  But it wasn't a solution to
truly declarative and reproducible linux environments. 

Enter: [NixOS](https://nixos.org/).

I imagine I discovered NixOS after using the words "declarative"
or "reproducible".
[Oof](https://www.reddit.com/r/NixOS/comments/1612dt4/reproducible/).
At any rate, NixOS ended up being a near perfect match with what
I had been chasing for the last 6+ years of using linux.
Specifically, the nix tool "Home Manager" replaced all of my
janky bash scripts/yadm/the ansible of old. If interested, [this
was one of the
blogs](http://ghedam.at/24353/tutorial-getting-started-with-home-manager-for-nix) 
which inspired me to make the jump.
