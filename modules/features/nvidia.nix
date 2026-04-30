{
  self,
  inputs,
  config,
  ...
}:
{

  flake.nixosModules.nvidia =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {

      nixpkgs.config.allowUnfree = true;

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [
          nvidia-vaapi-driver # VA-API via NVDEC
        ];
      };

      services.xserver.videoDrivers = [ "nvidia" ];

      hardware.nvidia = {
        open = true;
        modesetting.enable = true;
        package = config.boot.kernelPackages.nvidiaPackages.latest;
        powerManagement.enable = true;
        # Required for VA-API to work with open modules (driver 595+)
        videoAcceleration = true;
      };

      boot.initrd.kernelModules = [
        "nvidia"
        "nvidia_modeset"
        "nvidia_uvm"
        "nvidia_drm"
      ];

      # Tell VA-API to use the nvidia driver
      environment.sessionVariables = {
        LIBVA_DRIVER_NAME = "nvidia";
        # Needed for Firefox VA-API in the RDD sandbox
        MOZ_DISABLE_RDD_SANDBOX = "1";
        # Disables the forced power boost the GPU gets when CUDA is activated. This should reduce the power usage when decoding video
        CUDA_DISABLE_PERF_BOOST = "1";

        # Increase Nvidia's shader cache size to 12GB
        __GL_SHADER_DISK_CACHE_SIZE = "12000000000";

      };

      # Firefox hardware acceleration
      # programs.firefox.preferences = let
      #  ffVersion = config.programs.firefox.package.version;
      # in {
      # FF 137+ uses force-enabled; older used vaapi.enabled
      # "media.ffmpeg.vaapi.enabled"               = lib.versionOlder ffVersion "137.0.0";
      #"media.hardware-video-decoding.force-enabled" = lib.versionAtLeast ffVersion "137.0.0";
      #"gfx.x11-egl.force-enabled"               = true;
      #"widget.dmabuf.force-enabled"              = true;
      # Blackwell (5000-series) supports AV1 decode — set true if confirmed via vainfo
      #"media.av1.enabled"                        = true;
      #};

    };
}
