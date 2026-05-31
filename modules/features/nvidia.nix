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
        # package = config.boot.kernelPackages.nvidiaPackages.new_feature;
        package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
          version = "610.43.02";
          sha256_64bit = "sha256-MDSgVLtM33dS/43CclZMsQVROAS/9TU4lFkBsWyndGM=";
          sha256_aarch64 = "sha256-isWTnokUA/dzWocFBLalnk4+O5gSExVjs3dVpdYTU88=";
          openSha256 = "sha256-hP5NVZZ4vGsACHLmUDKq4uckpd/kn1GxCSYnnJfAuBs=";
          settingsSha256 = "sha256-0YAhufRgjDW+uR+kjaTb154fibpcDw8QowfrucoZsKE=";
          persistencedSha256 = "sha256-Whgv9X+v2fRhzliOl2LzltY9v1SxDafFfv3IUPqj/hk=";
        };
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
