# Self-hosted git server: gitolite backend + two cgit web UIs.
#
# Two cgit instances scan the same repo dir:
#   - `private` (port `cfg.privatePort`) — shows everything.
#   - `public`  (port `cfg.publicPort`)  — shows only repos marked "visibility=false"

# Both bind to wt0 only. The intent is to route `publicPort` to the internet
# externally (e.g. Netbird routing); this module keeps the firewall closed.
#
# A repo opts into the public instance by setting `config gitweb.public = "1"`
# in its `gitolite.conf` stanza. A POST_COMPILE trigger (see `markerTrigger`)
# walks all bare repos after each gitolite redeploy and touches/removes the
# export marker to match. Default is private (marker absent).
#
# Admin keys are managed declaratively via `adminPubkeys`.
# Guest keyg are managed declaratively via `guestPubkeys`.
{
  config,
  lib,
  pkgs,
  ...
}:
let
in
{

}
