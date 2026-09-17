{ config, lib, ... }:
let
  cfg = config.modules.services.authelia;
in
{
  options.modules.services.authelia = {
    enable = lib.mkEnableOption "Authelia SSO server";
  };

  config = lib.mkIf cfg.enable {
    # Secrets loaded via systemd LoadCredential — root ownership (default) is fine.
    sops.secrets = {
      "authelia/jwt-secret"              = {};
      "authelia/storage-encryption-key"  = {};
      "authelia/oidc-hmac-secret"        = {};
      "authelia/oidc-issuer-private-key" = {};
      "authelia/user-password-hash"      = {};
    };

    # Authelia reads this file directly at runtime, so it must be owned by authelia-main.
    sops.templates."authelia-users" = {
      content = ''
        users:
          ajlow:
            displayname: "Alec Lowry"
            email: "alowry@sram.com"
            password: "${config.sops.placeholder."authelia/user-password-hash"}"
            groups:
              - admins
              - users
      '';
      owner = "authelia-main";
      mode = "0400";
    };

    services.authelia.instances.main = {
      enable = true;
      secrets = {
        jwtSecretFile            = config.sops.secrets."authelia/jwt-secret".path;
        storageEncryptionKeyFile = config.sops.secrets."authelia/storage-encryption-key".path;
        oidcHmacSecretFile       = config.sops.secrets."authelia/oidc-hmac-secret".path;
        oidcIssuerPrivateKeyFile = config.sops.secrets."authelia/oidc-issuer-private-key".path;
      };
      settings = {
        server.address = "tcp://0.0.0.0:9091/";
        session.cookies = [
          {
            domain = "internal.aleclowry.com";
            authelia_url = "https://authelia.internal.aleclowry.com";
          }
        ];
        storage.local.path = "/var/lib/authelia-main/db.sqlite3";
        notifier.filesystem.filename = "/var/lib/authelia-main/notifications.txt";
        authentication_backend.file.path = config.sops.templates."authelia-users".path;
        access_control.default_policy = "one_factor";
        identity_providers.oidc = {
          # client_secret values are bcrypt hashes of the plaintext stored in sops.
          # To regenerate a hash from the stored plaintext:
          #   SECRET=$(sops --decrypt --extract '["authelia"]["oidc"]["<id>-client-secret"]' secrets/common.yaml)
          #   nix run nixpkgs#authelia -- crypto hash generate bcrypt --password "$SECRET" --no-confirm
          clients = [
            {
              client_id = "immich";
              client_secret = "$2b$12$NN/hb7EgXySKs94xu/ZwaOXtM53xCed0wQj2zILHhPK1JSw.Sm82q";
              authorization_policy = "one_factor";
              redirect_uris = [
                "https://immich.internal.aleclowry.com/auth/login"
                "https://immich.internal.aleclowry.com/user-settings"
              ];
              scopes = [ "openid" "profile" "email" ];
            }
            {
              client_id = "forgejo";
              client_secret = "$2b$12$D0MtrL1aTOriv.TfZMigmO9184dxc6RL59CT14UfmMMd9oCMVbhW2";
              authorization_policy = "one_factor";
              redirect_uris = [
                "https://git.internal.aleclowry.com/user/oauth2/authelia/callback"
              ];
              scopes = [ "openid" "profile" "email" "groups" ];
            }
            {
              client_id = "mealie";
              client_secret = "$2b$12$ZezfJDS9Cg.3ctmtBwf29.Wvfcft47BXolgDYgh5/PI3K94EmLKUG";
              authorization_policy = "one_factor";
              redirect_uris = [
                "https://mealie.internal.aleclowry.com/login"
              ];
              scopes = [ "openid" "profile" "email" "groups" ];
            }
          ];
        };
      };
    };

    # Reachable from do-prod-01's Caddy over the Netbird mesh for forward_auth checks.
    networking.firewall.interfaces.wt0.allowedTCPPorts = [ 9091 ];
  };
}
