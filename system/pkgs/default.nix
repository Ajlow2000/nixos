{ ... }:
{
  nixpkgs.overlays = [
    (final: _: {
pijul-nest = final.callPackage ./pijul-nest.nix { };
      glance-agent = final.callPackage ./glance-agent.nix { };
      freshrss-share-to-linkwarden = final.callPackage ./freshrss-share-to-linkwarden.nix { };
    })
  ];
}
