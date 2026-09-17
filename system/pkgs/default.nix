{ ... }:
{
  nixpkgs.overlays = [
    (final: _: {
      lore = final.callPackage ./lore.nix { };
      pijul-nest = final.callPackage ./pijul-nest.nix { };
      glance-agent = final.callPackage ./glance-agent.nix { };
    })
  ];
}
