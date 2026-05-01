{ self, inputs, ... }:
{

  flake.nixosModules.gaming =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {

      #  ── Kernel tweaks (optional, uncomment to enable) ─────────────────────

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
            renice = 10;
            inhibit_screensaver = 1;
          };
          gpu = {
            apply_gpu_optimisations = "accept-responsibility";
            gpu_device = 0;
            nv_powermizer_mode = 1; # NVIDIA: prefer maximum performance
          };
          cpu = {
            park_cores = "no";
            pin_cores = "yes";
          };
        };
      };

      # ── Gamescope ─────────────────────────────────────────────────────────

      programs.gamescope = {
        enable = true;
      };

      # ── Steam ─────────────────────────────────────────────────────────────

      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        gamescopeSession.enable = true;
        protontricks.enable = true;
        extraPackages = with pkgs; [
          libsecret
        ];
      };

      # ── Services ────────────────────────────────────────────────────────────
      services.lact.enable = true;

      # ── FFXIV BINDINGS ───────────────────────────────────────────────────────
      services.kanata = {
        enable = true;
        keyboards.ffxiv = {
          devices = [
            # The verified interface for the Aerox 9 side buttons
            "/dev/input/by-id/usb-SteelSeries_SteelSeries_Aerox_9_Wireless-if05-event-kbd"
          ];
          extraDefCfg = "process-unmapped-keys yes";
          config = ''
            (defsrc
              1 2 3 pause
            )
            (deflayer ffxiv
              left down right del
            )
          '';
        };
      };

      # Prevent the service from grabbing the mouse on system boot
      systemd.services.kanata-ffxiv.wantedBy = lib.mkForce [ ];

      # Sudo rules allowing your wrapper script to start/stop the preset
      security.sudo.extraRules = [
        {
          users = [ "moara" ];
          commands = [
            {
              command = "/run/current-system/sw/bin/systemctl start kanata-ffxiv.service";
              options = [ "NOPASSWD" ];
            }
            {
              command = "/run/current-system/sw/bin/systemctl stop kanata-ffxiv.service";
              options = [ "NOPASSWD" ];
            }
          ];
        }
      ];

      systemd.user.services.kanata-ffxiv-watcher = {
        description = "Auto-toggle Kanata when FFXIV is running";
        wantedBy = [ "default.target" ];
        path = [ pkgs.procps ];
        script = ''
          is_running=false

          while true; do
            if pgrep -x "ffxiv_dx11.exe" > /dev/null; then
              if [ "$is_running" = false ]; then
                echo "FFXIV detected, starting Kanata..."
                # Using the absolute path for both sudo and systemctl
                /run/wrappers/bin/sudo /run/current-system/sw/bin/systemctl start kanata-ffxiv.service
                is_running=true
              fi
            else
              if [ "$is_running" = true ]; then
                echo "FFXIV closed, stopping Kanata..."
                /run/wrappers/bin/sudo /run/current-system/sw/bin/systemctl stop kanata-ffxiv.service
                is_running=false
              fi
            fi
            
            sleep 3
          done
        '';
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
        faugus-launcher # Feature-rich third-party game launcher
        heroic # Native Epic / GOG / Amazon launcher (Wayland-first)
        # lutris                 # GOG, Epic, Battle.net, custom runners
        # bottles                # Wine/Proton manager with per-game sandboxing

        # Performance overlay & monitoring
        mangohud # In-game FPS / GPU / CPU / VRAM / frametime overlay
        mangojuice # MangoHud config editor
        # goverlay               # Alternative MangoHud GUI editor
        nvtopPackages.nvidia # Live GPU process monitor

        # Proton / Wine tooling
        protonplus # GE-Proton & Wine-GE download manager
        #wine-staging # Wine with staging patches
        wineWow64Packages.full
        winetricks # Install Windows runtimes into Wine prefixes
        #protontricks # winetricks fork for games
        # protonup-qt            # Alternative GE-Proton manager

        # GPU tuning
        lact # NVIDIA/AMD GPU overclocking & fan control
        # corectrl               # Alternative GPU tuning GUI

        # Capture & streaming
        obs-studio
        gpu-screen-recorder

        # Controller & input
        # antimicrox             # Remap gamepad buttons to keyboard/mouse
        # oversteer              # Force-feedback tuning for steering wheels

        # Vulkan / OpenGL diagnostics
        vulkan-tools # vulkaninfo, vkcube
        mesa-demos # glxinfo, glxgears

        # Other
        fflogs
        sgdboop

      ];
    };
}
