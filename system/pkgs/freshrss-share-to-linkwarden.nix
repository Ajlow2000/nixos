{ freshrss-extensions, fetchFromGitHub }:
freshrss-extensions.buildFreshRssExtension {
  pname = "share-to-linkwarden";
  version = "0.1.0-unstable-2025-12-01";
  FreshRssExtUniqueId = "ShareToLinkwarden";

  src = fetchFromGitHub {
    owner = "daften";
    repo = "xExtension-ShareToLinkwarden";
    rev = "7bce853f52737949feaf290c9a6435ea36b37599";
    hash = "sha256-bLNFHqYfgEGneZy7Jz0hkBICZCDG5M/6b1xeiSHKu4c=";
  };
}
