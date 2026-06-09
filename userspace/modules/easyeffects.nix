{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.easyeffects;

  # Shared LSP sidechain subobject used by gate and compressor.
  lspSidechain = {
    type = "Internal";
    mode = "RMS";
    source = "Middle";
    "stereo-split-source" = "Left/Right";
    preamp = 0.0;
    reactivity = 10.0;
    lookahead = 5.0;
  };
in
{
  options = {
    easyeffects.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf (cfg.enable && pkgs.stdenv.isLinux) {
    services.easyeffects = {
      enable = true;
      preset = "noise-suppression";
      extraPresets.noise-suppression = {
        input = {
          blocklist = [ ];
          plugins_order = [
            "gate#0"
            "deepfilternet#0"
            "compressor#0"
            "limiter#0"
          ];

          "gate#0" = {
            bypass = false;
            "input-gain" = 0.0;
            "output-gain" = 0.0;
            dry = -100.0;
            wet = 0.0;
            attack = 3.0;
            release = 200.0;
            "curve-threshold" = -32.0;
            "curve-zone" = -6.0;
            hysteresis = true;
            "hysteresis-threshold" = -38.0;
            "hysteresis-zone" = -6.0;
            reduction = -24.0;
            makeup = 0.0;
            "stereo-split" = false;
            "hpf-mode" = "12 dB/oct";
            "hpf-frequency" = 100.0;
            "lpf-mode" = "off";
            "lpf-frequency" = 20000.0;
            sidechain = lspSidechain;
          };

          "deepfilternet#0" = {
            bypass = false;
            "input-gain" = 0.0;
            "output-gain" = 0.0;
            "attenuation-limit" = 60.0;
            "min-processing-threshold" = -10.0;
            "max-erb-processing-threshold" = 30.0;
            "max-df-processing-threshold" = 20.0;
            "min-processing-buffer" = 0;
            "post-filter-beta" = 0.02;
          };

          "compressor#0" = {
            bypass = false;
            "input-gain" = 0.0;
            "output-gain" = 0.0;
            dry = -100.0;
            wet = 0.0;
            mode = "Downward";
            threshold = -16.0;
            ratio = 2.5;
            attack = 10.0;
            release = 150.0;
            knee = -6.0;
            makeup = 4.0;
            "stereo-split" = false;
            "hpf-mode" = "off";
            "hpf-frequency" = 10.0;
            "lpf-mode" = "off";
            "lpf-frequency" = 20000.0;
            "boost-amount" = 6.0;
            "boost-threshold" = -72.0;
            sidechain = lspSidechain;
          };

          "limiter#0" = {
            bypass = false;
            "input-gain" = 0.0;
            "output-gain" = 0.0;
            mode = "Herm Thin";
            oversampling = "None";
            dithering = "None";
            "sidechain-type" = "Internal";
            lookahead = 5.0;
            attack = 5.0;
            release = 5.0;
            threshold = -1.0;
            "sidechain-preamp" = 0.0;
            "stereo-link" = 100.0;
            alr = false;
            "alr-attack" = 5.0;
            "alr-release" = 50.0;
            "alr-knee" = 0.0;
            "gain-boost" = true;
          };
        };
      };
    };
  };
}
