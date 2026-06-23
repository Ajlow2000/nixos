{ keys, ... }:
{
  # The ajlow private key is sops-deployed to ~/.ssh/id_ed25519 (system module).
  # Keep the matching .pub in sync declaratively so it never goes stale and ssh
  # always offers the right identity (a mismatched leftover .pub makes ssh fail
  # with "private key contents do not match public" and fall back to password).
  home.file.".ssh/id_ed25519.pub".text = keys.ajlow + "\n";
}
