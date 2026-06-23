{
  ajlow = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEu6OuWSqLq1EcoZ6sBVmUhfc/WHIIW+s+yK7Y86ckGu ajlow_2026-06-22";

  root = {
      hal9000       = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPnRHwhbaOEEuUnfHjek3WKbSCXFnEZBJ2zgs2l3DXeP root@hal9000";
      microvac      = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIiP8fRhoOUXLwWmtPfX361r7cv8VCryKtKoZ21PSVhT root@microvac_2026-06-22";
      mindgame      = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIMRnK9Uo43JWuNSH/dOc6/ALyEtms/AXMqGWgsLIdPK root@mindgame_2026-06-22";
      do-prod-01    = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJgVRvyuY4hNXqo2a1q+T+R4gtmptYGQ6xWtYliB0bke root@do-prod-01_2026-06-22";
  };


  # AGE IDENTITY STUBS FOR SOPS
  # ---------------------------
  # Stubs that tell age which YubiKey + PIV slot to use when decrypting sops
  # files. These are NOT secret — they only reference the hardware. Without
  # the physical YubiKey inserted, they cannot decrypt anything.
  #
  # Generate per YubiKey, with the key inserted:
  #   age-plugin-yubikey --identity
  #
  # The bare AGE-PLUGIN-YUBIKEY-1... line is what goes below. Add one entry
  # per YubiKey.
  sops-age-identities = [
    # YubiKey 1 (slot 1, name sops-admin-yubikey-01)
    "AGE-PLUGIN-YUBIKEY-1RXUAQQVZE2AD5JQTXYDMW"
    # YubiKey 2 (slot 1, name sops-admin-yubikey-02)
    "AGE-PLUGIN-YUBIKEY-1JWADQQVZRNMJZSQ65LQSP"
  ];
}
