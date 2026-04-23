{ self, inputs, ... }: {

  flake.nixosModules.zram = { lib, config, ... }: let
    cfg = config.custom.zram;
  in {
    options.custom.zram = {
      enable = lib.mkEnableOption "Enable utils module";
    };

    config = lib.mkIf cfg.enable {
      zramSwap = {
        enable = true;
        algorithm = "zstd";
        priority = 5;
        memoryPercent = 100;
      };
    };
  };

}
