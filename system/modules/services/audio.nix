{ config, lib, pkgs, ... }:
let
    cfg = config.modules.services.audio;
in {
    options.modules.services.audio = {
        enable = lib.mkEnableOption "PipeWire audio system";
    };

    config = lib.mkIf cfg.enable {
        # Disable PulseAudio in favor of PipeWire
        services.pulseaudio.enable = false;

        # Enable rtkit for realtime scheduling
        security.rtkit.enable = true;

        # Enable PipeWire with ALSA and PulseAudio support
        services.pipewire = {
            enable = true;
            alsa.enable = true;
            alsa.support32Bit = true;
            pulse.enable = true;
        };
    };
}
