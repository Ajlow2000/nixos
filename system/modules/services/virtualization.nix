{ config, lib, pkgs, ... }:
let
    cfg = config.modules.services.virtualization;

    # Pin QEMU to a specific nixpkgs commit to avoid VM boot issues after updates
    # Current pinned commit: 3497aa5c9457a9d88d71fa93a4a8368816fbeeba (current flake.lock)
    # To update QEMU: change the rev below, rebuild, then update your VM configs
    pinnedNixpkgs = import (builtins.fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/3497aa5c9457a9d88d71fa93a4a8368816fbeeba.tar.gz";
    }) { inherit (pkgs) system; };

    pinnedQemu = pinnedNixpkgs.qemu_kvm;
in {
    options.modules.services.virtualization = {
        enable = lib.mkEnableOption "libvirt/QEMU virtualization with virt-manager";

        users = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
            description = "Users to add to virtualization groups (libvirtd, kvm, qemu-libvirtd)";
        };

        pinQemu = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Pin QEMU to a specific version to prevent VM boot issues after updates";
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
            qemu = {
                package = lib.mkIf cfg.pinQemu pinnedQemu;
                swtpm.enable = true;
            };
        };
    };
}
