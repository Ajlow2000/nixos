/*
  SSH Key Reference
  =================

  Keys are organized by identity. Each identity contains both device keys
  (trusted machines) and YubiKey resident keys mixed together. All keys in
  an identity are deployed to that user's authorized_keys.

    keys.personal  ->  ajlow  user's authorized_keys
    keys.sram      ->  alowry user's authorized_keys

  DEVICE KEYS
  -----------
  Standard ed25519 keys tied to a specific machine. Generate once per trusted
  host, store the private key on that machine, and add the public key here.

  Generate:
    ssh-keygen -t ed25519 -C "user@hostname" -f ~/.ssh/id_ed25519_$(hostname)

  Get the public key to paste here:
    cat ~/.ssh/id_ed25519_$(hostname).pub

  Store the private key in Bitwarden as an "SSH Key" item (label: "user@hostname
  device key") as a backup in case you need to recover or move it.

  YUBIKEY RESIDENT KEYS
  ----------------------
  FIDO2 resident keys are stored directly on the YubiKey hardware. The private
  key never touches disk. Touch (and optionally PIN) is required to use them.
  Resident means they can be re-exported to a new machine without re-registering
  everywhere — you just need the key inserted.

  Generate (run once per identity per YubiKey, with the key inserted):
    ssh-keygen -t ed25519-sk \
      -O resident \
      -O application=ssh:personal \
      -O verify-required \
      -C "ajlow@yubikey-01" \
      -f ~/.ssh/id_ed25519_sk_personal

  Flags:
    -O resident          Store credential on the YubiKey (required for re-export)
    -O application=ssh:* Label for the credential slot; must start with "ssh:"
    -O verify-required   Require PIN in addition to touch (recommended)

  Repeat with -O application=ssh:sram and a different -f path for the sram identity.
  Repeat the whole process for the second YubiKey (backup).

  RETRIEVING PUBLIC KEYS FROM A YUBIKEY
  ---------------------------------------
  If you have a new machine and need to get the public key off the YubiKey:

  Export resident key handles to current directory (creates .pub files):
    ssh-keygen -K

  This writes id_ed25519_sk_rk_<label> and id_ed25519_sk_rk_<label>.pub files.
  The .pub file contains the public key to paste here. The private "key handle"
  file is safe to have on disk — it is useless without the physical YubiKey.

  Load resident keys directly into ssh-agent (requires touch):
    ssh-add -K

  List what credentials are currently stored on an inserted YubiKey:
    ykman fido credentials list

  USING A YUBIKEY ON AN UNMANAGED COMPUTER
  -----------------------------------------
  FIDO2 keys are secure on untrusted machines by design — the private key never
  leaves the hardware. Every SSH connection requires the YubiKey to physically
  perform the signature, so removing it immediately blocks any further auth.
  This is guaranteed by the protocol, not by configuration.

  Workflow:
    # 1. Insert YubiKey, load resident keys into the agent (no files written to disk)
    ssh-add -K
    # Touch the key when prompted.

    # 2. Verify it loaded
    ssh-add -l

    # 3. Do git work — each new connection (clone, push, pull) requires a touch
    git clone git@github.com:you/repo.git
    git push origin main

    # 4. When done, optionally clear the agent (removing the key is sufficient)
    ssh-add -D

  Caveats:

  SSH ControlMaster: if the machine has ControlMaster+ControlPersist configured,
  an existing multiplexed connection can be reused without re-authing. Unlikely on
  a random machine, but override with: ssh -o ControlMaster=no

  PIN caching: with -O verify-required, the FIDO2 library may cache the PIN for
  the session so you aren't re-prompted every touch. Touch is still required per
  connection regardless.

  libfido2 required: the machine needs libfido2 installed for OpenSSH to talk to
  the YubiKey. Install if missing:
    Debian/Ubuntu:  apt install libfido2-1
    Fedora/RHEL:    dnf install libfido2

  udev rules: some distros don't ship YubiKey udev rules. If ssh-add -K can't find
  the device, install yubikey-manager or the libu2f-udev package for your distro.

  AFTER ADDING A KEY HERE
  ------------------------
  Run `nixos-rebuild switch` (or deploy) on any host whose authorized_keys
  should include the new key. The authorized_keys composition is defined in
  system/modules/user-definitions.nix and system/profiles/digital-ocean.nix.
*/
{
  personal = {
    # --- Device keys (trusted machines) ---
    microvac = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIISwx1LSpeS2WnL3STLX+bQPG1A9Im/ue/q2DtViFcd+ ajlow@microvac";
    # hal9000  = "ssh-ed25519 AAAA... ajlow@hal9000";
    # mindgame = "ssh-ed25519 AAAA... ajlow@mindgame";
    # multivac = "ssh-ed25519 AAAA... ajlow@multivac";

    # --- YubiKey resident keys ---
    # yubikey-01 = "sk-ssh-ed25519@openssh.com AAAA... ajlow@yubikey-01";
    # yubikey-02 = "sk-ssh-ed25519@openssh.com AAAA... ajlow@yubikey-02";
  };

  sram = {
    # --- Device keys (trusted machines) ---
    # marvin = "ssh-ed25519 AAAA... alowry@marvin";

    # --- YubiKey resident keys ---
    # yubikey-01 = "sk-ssh-ed25519@openssh.com AAAA... alowry@yubikey-01";
    # yubikey-02 = "sk-ssh-ed25519@openssh.com AAAA... alowry@yubikey-02";
  };
}
