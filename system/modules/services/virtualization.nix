{ config, lib, pkgs, ... }:
let
    cfg = config.modules.services.virtualization;
in {
    options.modules.services.virtualization = {
        enable = lib.mkEnableOption "libvirt/QEMU virtualization with virt-manager";

        users = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
            description = "Users to add to virtualization groups (libvirtd, kvm, qemu-libvirtd)";
        };
    };

    config = lib.mkIf cfg.enable {
        programs.virt-manager.enable = true;

        # Add specified users to virtualization groups
        users.users = builtins.listToAttrs (
            map (user: {
                name = user;
                value = {
                    extraGroups = [ "libvirtd" "kvm" "qemu-libvirtd" ];
                };
            }) cfg.users
        );

        environment.systemPackages = with pkgs; [
            virtiofsd
            virt-manager
            virtio-win
        ];

        environment.sessionVariables.LIBVIRT_DEFAULT_URI = [ "qemu:///system" ];

        virtualisation.libvirtd = {
            enable = true;
            qemu.swtpm.enable = true;
        };
    };
}
