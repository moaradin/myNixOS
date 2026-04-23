{ self, inputs, ... }: {

  flake.nixosModules.gaming = { pkgs, lib, config, ... }: {

    # ── Kernel tweaks (optional, uncomment to enable) ─────────────────────

    # boot.kernel.sysctl = {
    #   "vm.max_map_count"            = 2147483642; # Required by many games (Star Citizen, Elden Ring, anti-cheat)
    #   "vm.swappiness"               = 10;         # Strongly prefer RAM over swap
    #   "vm.dirty_ratio"              = 10;         # Reduce latency spikes from dirty page writeback
    #   "vm.dirty_background_ratio"   = 5;
    #   "net.core.netdev_max_backlog" = 16384;      # Faster network for online gaming
    # };

    # boot.kernelParams = [
    #   "nowatchdog"                   # Reduces latency jitter
    #   "transparent_hugepage=madvise" # Let games opt-in to huge pages
    #   "preempt=full"                 # Full preemption for lower input latency
    # ];

    # powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

    # ── GameMode ──────────────────────────────────────────────────────────

    programs.gamemode = {
      enable = true;
      settings = {
        general = {
          renice              = 10;
          inhibit_screensaver = 1;
        };
        gpu = {
          apply_gpu_optimisations = "accept-responsibility";
          gpu_device              = 0;
          nv_powermizer_mode      = 1; # NVIDIA: prefer maximum performance
        };
        cpu = {
          park_cores = "no";
          pin_cores  = "yes";
        };
      };
    };

    # ── Gamescope ─────────────────────────────────────────────────────────

    programs.gamescope = {
      enable     = true;
      capSysNice = true;
    };

    # ── Steam ─────────────────────────────────────────────────────────────

    programs.steam = {
      enable                       = true;
      remotePlay.openFirewall      = true;
      dedicatedServer.openFirewall = true;
      gamescopeSession.enable      = true;
      # extraCompatPackages = with pkgs; [
      #   proton-ge-bin              # Community Proton with extra patches & codecs
      # ];
    };
    

    # ── NVIDIA gaming variables (optional, uncomment to enable) ───────────

    # environment.sessionVariables = {
    #   __GL_SYNC_TO_VBLANK = "0";   # Disable driver-level vsync
    #   DXVK_ASYNC          = "1";   # Async shader compilation — reduces stutter
    #   VKD3D_CONFIG        = "dxr"; # Ray-tracing support via VKD3D-Proton
    #   PROTON_USE_WINED3D  = "0";   # Prefer Vulkan over OpenGL
    #   SDL_VIDEODRIVER     = "wayland";
    # };

    # security.unprivilegedUsernsClone = true; # Steam sandbox & some anti-cheat

    # ── Firewall ports (optional, uncomment to enable) ────────────────────

    # networking.firewall = {
    #   allowedTCPPortRanges = [
    #     { from = 27015; to = 27030; } # Steam game servers
    #     { from = 27036; to = 27037; } # Steam Remote Play
    #   ];
    #   allowedUDPPortRanges = [
    #     { from = 27015; to = 27030; } # Steam game servers
    #     { from = 4380;  to = 4380;  } # Steam client
    #   ];
    # };

    # ── Packages ──────────────────────────────────────────────────────────

    environment.systemPackages = with pkgs; [

      # Launchers
      faugus-launcher        # Feature-rich third-party game launcher
      heroic                 # Native Epic / GOG / Amazon launcher (Wayland-first)
      # lutris                 # GOG, Epic, Battle.net, custom runners
      # bottles                # Wine/Proton manager with per-game sandboxing

      # Performance overlay & monitoring
      mangohud               # In-game FPS / GPU / CPU / VRAM / frametime overlay
      mangojuice             # MangoHud config editor
      # goverlay               # Alternative MangoHud GUI editor
      nvtopPackages.nvidia   # Live GPU process monitor

      # Proton / Wine tooling
      protonplus             # GE-Proton & Wine-GE download manager
      wine-staging           # Wine with staging patches
      winetricks             # Install Windows runtimes into Wine prefixes
      # protonup-qt            # Alternative GE-Proton manager

      # GPU tuning
      lact                   # NVIDIA/AMD GPU overclocking & fan control
      # corectrl               # Alternative GPU tuning GUI

      # Capture & streaming
      obs-studio

      # Controller & input
      # antimicrox             # Remap gamepad buttons to keyboard/mouse
      # oversteer              # Force-feedback tuning for steering wheels

      # Vulkan / OpenGL diagnostics
      vulkan-tools           # vulkaninfo, vkcube
      mesa-demos             # glxinfo, glxgears

    ];

  };
}
