{ config, lib, pkgs, ... }:
let 
    cfg = config.work;
in {
    imports = [
        ./server.nix
        ../modules/display-manager.nix
        ../modules/desktop-environment.nix
    ];

    options = {
        work.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
        };
    };

    config = lib.mkIf cfg.enable {
        server.enable = true;
        display-manager.enable = true;
        desktop-environment.enable = true;

        programs.noisetorch.enable = true;

        hardware.opentabletdriver.enable = true;
        hardware.opentabletdriver.daemon.enable = true;

        environment.systemPackages = with pkgs; [
            wineWowPackages.stable
            firefox
            virtiofsd
            virt-manager
            win-virtio
        ];

        # Configure keymap in X11
        services.xserver.xkb = {
            layout = "us";
            variant = "";
        };

        virtualisation.docker = {
            enable = true;
            # rootless.enable = true;
            # rootless.setSocketVariable = true;
            daemon.settings.data-root = "$XDG_DATA_HOME/docker";
        };

        services.printing.enable = true;

        programs.firefox.enable = true;

        programs.virt-manager.enable = true;

        users.users.ajlow = {
            extraGroups = [ "libvirtd" "kvm" "qemu-libvirtd" ];
        };

        environment.sessionVariables.LIBVIRT_DEFAULT_URI = [ "qemu:///system" ];

        virtualisation = {
              libvirtd = {
                enable = true;
                qemu.ovmf.enable = true;
                qemu.swtpm.enable = true;
                # qemuOvmfPackage = pkgs.OVMFFull;
            };
        };

        # Enable sound with pipewire.
        services.pulseaudio.enable = false;
        security.rtkit.enable = true;
        services.pipewire = {
            enable = true;
            alsa.enable = true;
            alsa.support32Bit = true;
            pulse.enable = true;
            # If you want to use JACK applications, uncomment this
            #jack.enable = true;

            # use the example session manager (no others are packaged yet so this is enabled by default,
            # no need to redefine it in your config for now)
            #media-session.enable = true;
        };

        # Enable touchpad support (enabled default in most desktopManager).
        # services.xserver.libinput.enable = true;
    };
}
