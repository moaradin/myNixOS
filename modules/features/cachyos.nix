{ self, inputs, ... }: {
  flake.nixosModules.cachyos = { pkgs, ... }: {
    nixpkgs.overlays = [
      # "pinned" ensures binary cache hits — kernels are pre-built by Hydra CI
      inputs.nix-cachyos-kernel.overlays.pinned
    ];

    # 9800X3D = Zen 4, so zen4 variant uses -march=znver4 optimizations
    boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-zen4;

    # Binary caches — without these you'd be compiling the kernel locally
    nix.settings = {
      substituters = [
        "https://attic.xuyh0120.win/lantian"  # Primary: Hydra CI cache
        "https://cache.garnix.io"             # Fallback: Garnix CI cache
      ];
      trusted-public-keys = [
        "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      ];
    };
  };
}
