{ self, inputs, ... }: {
  flake.nixosModules.niri = { pkgs, lib, ... }: {
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri;
    };

    services.greetd = {
      enable = true;
      settings.default_session = {
        command = "niri-session";
        user = "moara";
      };
    };

    environment.systemPackages = with pkgs; [
      wl-clipboard
      nautilus
      gnome-text-editor
      papirus-icon-theme
      adw-gtk3
      nwg-look
      kdePackages.qt6ct
      gnome-system-monitor
      # Keybind dependencies
      # playerctl
      # brightnessctl
      libnotify      # notify-send
    ];

    programs.dconf = {
      enable = true;
      profiles.user.databases = [{
        settings."org/gnome/desktop/interface".icon-theme = lib.gvariant.mkString "Papirus";
      }];
    };

    gtk.iconCache.enable = true;
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config.common.default = [ "gtk" ];
    };
  };

  perSystem = { pkgs, lib, self', ... }: {
    packages.myNiri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      settings = {

        # ============================================================
        # 1. ENVIRONMENT & CORE SETTINGS
        # ============================================================

        prefer-no-csd = true;

        workspaces = {
          "1"   = { open-on-output = "DP-2"; };
          "obs" = { open-on-output = "DP-2"; };
        };

        environment = {
          QT_QPA_PLATFORMTHEME = "qt6ct";
        };

        debug.honor-xdg-activation-with-invalid-serial = true;

        hotkey-overlay.skip-at-startup = true;

        clipboard.disable-primary = true;

        screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

        # ============================================================
        # 2. HARDWARE CONFIGURATION
        # ============================================================

        input = {
          keyboard = {
            xkb.layout = "us";
            numlock = true;
          };
          touchpad = {
            tap = true;
            natural-scroll = true;
          };
          mouse.accel-profile = "flat";
          focus-follows-mouse.max-scroll-amount = "0%";
        };

        outputs = {
          "DP-3" = {
            mode = "2560x1440@144.0";
            scale = 1.0;
            # DISABLED: A bug in the wrapper module prevents x/y properties from serializing correctly.
            # position = { x = 1920; y = 0; };
            focus-at-startup = true;
            variable-refresh-rate = "on-demand";
            hot-corners.off = {};
          };
          "DP-2" = {
            mode = "1920x1080@144.001";
            scale = 1.0;
            # DISABLED: A bug in the wrapper module prevents x/y properties from serializing correctly.
            # position = { x = 0; y = 340; };
            hot-corners.off = {};
          };
        };

        # ============================================================
        # 3. APPEARANCE & LAYOUT
        # ============================================================

        layout = {
          gaps = 16;
          center-focused-column = "never";

          preset-column-widths = [
            { proportion = 0.33333; }
            { proportion = 0.5; }
            { proportion = 0.66667; }
          ];

          default-column-width.proportion = 0.5;

          focus-ring = {
            width = 4;
            active-color = "#7fc8ff";
            inactive-color = "#505050";
          };

          border = {
            off = true;
            width = 4;
            active-color = "#ffc87f";
            inactive-color = "#505050";
            urgent-color = "#9b0000";
          };

          shadow = {
            softness = 30;
            spread = 5;
            # DISABLED: A bug in the wrapper module prevents x/y properties from serializing correctly.
            # offset = { x = 0; y = 5; };
            color = "#0007";
          };
        };

        animations = {};

        # ============================================================
        # 4. WINDOW RULES
        # ============================================================

        window-rules = [

          # Rounded corners for all windows
          {
            geometry-corner-radius = 20;
            clip-to-geometry = true;
          }

          # Work around WezTerm's initial configure bug
          {
            matches = [{ app-id = "^org\\.wezfurlong\\.wezterm$"; }];
            default-column-width = {};
          }

          # Firefox / Zen Picture-in-Picture — floating, pinned bottom-right
          {
            matches = [
              { app-id = "firefox$"; title = "^Picture-in-Picture$"; }
              { app-id = "zen$";     title = "^Picture-in-Picture$"; }
            ];
            open-floating = true;
            default-column-width.fixed = 473;
            default-window-height.fixed = 266;
            # DISABLED: A bug in the wrapper module prevents x/y properties from serializing correctly.
            # default-floating-position = { x = 20; y = 20; relative-to = "bottom-right"; };
          }

          # Steam notification toasts
          {
            matches = [{ app-id = "steam"; title = "^notificationtoasts_\\d+_desktop$"; }];
            # DISABLED: A bug in the wrapper module prevents x/y properties from serializing correctly.
            # default-floating-position = { x = 10; y = 10; relative-to = "bottom-right"; };
          }

          # VRR game support — force to DP-3
          {
            matches = [
              { app-id = "eldenring\\.exe"; }
              { app-id = "ffxiv_dx11\\.exe"; }
              { app-id = "steam_app_.*"; }
              { app-id = "gamescope"; }
            ];
            open-on-output = "DP-3";
            variable-refresh-rate = true;
          }

          # Genshin FPS Unlocker — hide off-screen on DP-2
          {
            matches = [
              { app-id = "steam_app_0";          title = "^Genshin FPS Unlocker$"; }
              { app-id = "steam_app_2527870827"; title = "^Genshin FPS Unlocker$"; }
              { app-id = "steam_app_0";          title = "^$"; }
              { app-id = "steam_app_2527870827"; title = "^$"; }
            ];
            open-on-output = "DP-2";
            open-floating = true;
            open-focused = false;
            # DISABLED: A bug in the wrapper module prevents x/y properties from serializing correctly.
            # default-floating-position = { x = -5000; y = -5000; relative-to = "top-right"; };
          }

          # Genshin Impact — main monitor
          {
            matches = [{ app-id = "steam_app_2527870827"; title = "^Genshin Impact$"; }];
            open-on-output = "DP-3";
          }

          # OBS / xdg-portal / Archon — obs workspace, unfocused
          {
            matches = [
              { app-id = "com.obsproject.Studio"; }
              { app-id = "xdg-desktop-portal-gnome"; }
              { app-id = "Archon App Beta"; }
            ];
            open-on-workspace = "obs";
            open-focused = false;
          }

          # Transparent windows with blur
          {
            matches = [
              { app-id = "org.gnome.Nautilus"; }
              { app-id = "org.gnome.TextEditor"; }
            ];
            draw-border-with-background = false;
            opacity = 0.80;
          }

          # Ghostty — no border background
          {
            matches = [{ app-id = "com.mitchellh.ghostty"; }];
            draw-border-with-background = false;
          }

        ];

        # ============================================================
        # 5. KEYBINDINGS
        # ============================================================

        binds = with lib; {

          # --- System & UI ---
          "Mod+Shift+Slash".show-hotkey-overlay = {};
          "Mod+Escape" = {
            allow-inhibiting = false;
            toggle-keyboard-shortcuts-inhibit = {};
          };
          "Mod+Shift+E".quit     = {};
          "Ctrl+Alt+Delete".quit = {};
          "Mod+Shift+P".power-off-monitors = {};

          # --- Noctalia Shell Controls ---
          "Mod+Space".spawn-sh    = "${getExe self'.packages.myNoctalia} ipc call launcher toggle";
          "Mod+S".spawn-sh        = "${getExe self'.packages.myNoctalia} ipc call controlCenter toggle";
          "Mod+Backspace".spawn-sh = "${getExe self'.packages.myNoctalia} ipc call settings toggle";
          "Mod+F12".spawn-sh      = "${getExe self'.packages.myNoctalia} ipc call plugin:screen-recorder toggle";
          "Mod+Alt+W".spawn-sh    = "${getExe self'.packages.myNoctalia} ipc call wallpaper get DP-3 | wl-copy | xargs notify-send 'Current Wallpaper'";

          # --- Applications ---
          "Mod+T" = {
            hotkey-overlay-title = "Open a Terminal: ghostty";
            repeat = false;
            spawn = [ "ghostty" ];
          };
          "Mod+A" = {
            hotkey-overlay-title = "Run an Application: nautilus";
            spawn-sh = "nautilus --new-window";
          };
          "Mod+E" = {
            # zen-browser: adjust package name to match your flake input/overlay
            hotkey-overlay-title = "Run an Application: zen";
            repeat = false;
            spawn = [ "zen-browser" ];
          };
          "Mod+D" = {
            hotkey-overlay-title = "Open Discord: Equibop";
            repeat = false;
            spawn = [ "equibop" ];
          };

          "Shift+Print".screenshot = {};
          # Package your niri-screenshot.sh as self'.packages.niriScreenshot
          "Print".spawn = [ "niri-screenshot" ];

          # --- Media & Hardware ---
          # "XF86AudioRaiseVolume" = {
          #   allow-when-locked = true;
          #   spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0";
          # };
          # "XF86AudioLowerVolume" = {
          #   allow-when-locked = true;
          #   spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-";
          # };
          # "XF86AudioMute" = {
          #   allow-when-locked = true;
          #   spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          # };
          # "XF86AudioMicMute" = {
          #   allow-when-locked = true;
          #   spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
          # };
          #"XF86AudioPlay" = {
          #  allow-when-locked = true;
          #  spawn-sh = "playerctl play-pause";
          #};
          #"XF86AudioStop" = {
          #  allow-when-locked = true;
          #  spawn-sh = "playerctl stop";
          #};
          #"XF86AudioPrev" = {
          #  allow-when-locked = true;
          #  spawn-sh = "playerctl previous";
          #};
          #"XF86AudioNext" = {
          #  allow-when-locked = true;
          #  spawn-sh = "playerctl next";
          #};
          # "XF86MonBrightnessUp" = {
          #   allow-when-locked = true;
          #   spawn = [ "brightnessctl" "--class=backlight" "set" "+10%" ];
          # };
          # "XF86MonBrightnessDown" = {
          #   allow-when-locked = true;
          #   spawn = [ "brightnessctl" "--class=backlight" "set" "10%-" ];
          # };

          # --- Window Focus & Movement ---
          "Mod+Q" = { repeat = false; close-window = {}; };
          "Mod+Left".focus-column-left  = {};
          "Mod+Down".focus-window-down  = {};
          "Mod+Up".focus-window-up      = {};
          "Mod+Right".focus-column-right = {};
          "Mod+H".focus-column-left  = {};
          "Mod+J".focus-window-down  = {};
          "Mod+K".focus-window-up    = {};
          "Mod+L".focus-column-right = {};

          "Mod+Ctrl+Left".move-column-left   = {};
          "Mod+Ctrl+Down".move-window-down   = {};
          "Mod+Ctrl+Up".move-window-up       = {};
          "Mod+Ctrl+Right".move-column-right = {};
          "Mod+Ctrl+H".move-column-left  = {};
          "Mod+Ctrl+J".move-window-down  = {};
          "Mod+Ctrl+K".move-window-up    = {};
          "Mod+Ctrl+L".move-column-right = {};

          "Mod+Home".focus-column-first      = {};
          "Mod+End".focus-column-last        = {};
          "Mod+Ctrl+Home".move-column-to-first = {};
          "Mod+Ctrl+End".move-column-to-last  = {};

          # --- Workspace & Monitor Management ---
          "Mod+O" = { repeat = false; toggle-overview = {}; };

          "Mod+Shift+Left".focus-monitor-left  = {};
          "Mod+Shift+Down".focus-monitor-down  = {};
          "Mod+Shift+Up".focus-monitor-up      = {};
          "Mod+Shift+Right".focus-monitor-right = {};
          "Mod+Shift+H".focus-monitor-left  = {};
          "Mod+Shift+J".focus-monitor-down  = {};
          "Mod+Shift+K".focus-monitor-up    = {};
          "Mod+Shift+L".focus-monitor-right = {};

          "Mod+Shift+Ctrl+Left".move-column-to-monitor-left  = {};
          "Mod+Shift+Ctrl+Down".move-column-to-monitor-down  = {};
          "Mod+Shift+Ctrl+Up".move-column-to-monitor-up      = {};
          "Mod+Shift+Ctrl+Right".move-column-to-monitor-right = {};
          "Mod+Shift+Ctrl+H".move-column-to-monitor-left  = {};
          "Mod+Shift+Ctrl+J".move-column-to-monitor-down  = {};
          "Mod+Shift+Ctrl+K".move-column-to-monitor-up    = {};
          "Mod+Shift+Ctrl+L".move-column-to-monitor-right = {};

          "Mod+Page_Down".focus-workspace-down = {};
          "Mod+Page_Up".focus-workspace-up     = {};
          "Mod+U".focus-workspace-down         = {};
          "Mod+I".focus-workspace-up           = {};
          "Mod+Ctrl+Page_Down".move-column-to-workspace-down = {};
          "Mod+Ctrl+Page_Up".move-column-to-workspace-up    = {};
          "Mod+Ctrl+U".move-column-to-workspace-down        = {};
          "Mod+Ctrl+I".move-column-to-workspace-up          = {};

          "Mod+Shift+Page_Down".move-workspace-down = {};
          "Mod+Shift+Page_Up".move-workspace-up     = {};
          "Mod+Shift+U".move-workspace-down         = {};
          "Mod+Shift+I".move-workspace-up           = {};

          # Mouse & Touchpad Scrolling
          "Mod+WheelScrollDown".focus-column-right       = {};
          "Mod+WheelScrollUp".focus-column-left          = {};
          "Mod+Shift+WheelScrollDown".move-column-right  = {};
          "Mod+Shift+WheelScrollUp".move-column-left     = {};
          "Mod+Ctrl+WheelScrollDown" = { cooldown-ms = 150; focus-workspace-down = {}; };
          "Mod+Ctrl+WheelScrollUp"   = { cooldown-ms = 150; focus-workspace-up   = {}; };
          "Mod+MouseForward".expel-window-from-column  = {};
          "Mod+MouseBack".consume-window-into-column   = {};

          # Workspace Number Navigation
          "Mod+1".focus-workspace = 1;
          "Mod+2".focus-workspace = 2;
          "Mod+3".focus-workspace = 3;
          "Mod+4".focus-workspace = 4;
          "Mod+5".focus-workspace = 5;
          "Mod+6".focus-workspace = 6;
          "Mod+7".focus-workspace = 7;
          "Mod+8".focus-workspace = 8;
          "Mod+9".focus-workspace = 9;
          "Mod+Ctrl+1".move-column-to-workspace = 1;
          "Mod+Ctrl+2".move-column-to-workspace = 2;
          "Mod+Ctrl+3".move-column-to-workspace = 3;
          "Mod+Ctrl+4".move-column-to-workspace = 4;
          "Mod+Ctrl+5".move-column-to-workspace = 5;
          "Mod+Ctrl+6".move-column-to-workspace = 6;
          "Mod+Ctrl+7".move-column-to-workspace = 7;
          "Mod+Ctrl+8".move-column-to-workspace = 8;
          "Mod+Ctrl+9".move-column-to-workspace = 9;

          # --- Layout Manipulation ---
          "Mod+BracketLeft".consume-or-expel-window-left   = {};
          "Mod+BracketRight".consume-or-expel-window-right = {};
          "Mod+Comma".consume-window-into-column  = {};
          "Mod+Period".expel-window-from-column   = {};

          "Mod+R".switch-preset-column-width        = {};
          "Mod+Shift+R".switch-preset-window-height = {};
          "Mod+Ctrl+R".reset-window-height          = {};
          "Mod+F".maximize-column                   = {};
          "Mod+Shift+F".fullscreen-window           = {};
          "Mod+Ctrl+F".expand-column-to-available-width = {};
          "Mod+C".center-column                     = {};
          "Mod+Ctrl+C".center-visible-columns       = {};
          "Mod+Alt+F".maximize-window-to-edges      = {};

          "Mod+Minus".set-column-width        = "-10%";
          "Mod+Equal".set-column-width        = "+10%";
          "Mod+Shift+Minus".set-window-height = "-10%";
          "Mod+Shift+Equal".set-window-height = "+10%";

          "Mod+V".toggle-window-floating                        = {};
          "Mod+Shift+V".switch-focus-between-floating-and-tiling = {};
          "Mod+W".toggle-column-tabbed-display                  = {};
        };

        # ============================================================
        # 6. AUTOSTART
        # ============================================================
        # NOTE: `include "./noctalia.kdl"` has no direct equivalent in the
        # Nix settings attrset. Merge noctalia.kdl's contents directly into
        # this settings block, or use extraConfig if your wrapper supports it.

        spawn-at-startup = [
          # replaces: spawn-at-startup "qs" "-c" "noctalia-shell" "--no-duplicate"
          (lib.getExe self'.packages.myNoctalia)

          # replaces: spawn-sh-at-startup "for i in {1..50}; do qs ... lockScreen lock ..."
          "${pkgs.writeShellScript "noctalia-lock-wait" ''
            for i in $(seq 1 50); do
              ${lib.getExe self'.packages.myNoctalia} ipc call lockScreen lock \
                > /dev/null 2>&1 && break || sleep 0.1
            done
          ''}"

          # replaces: spawn-at-startup "/home/moara/.config/niri/niri_tweaks/niri_tile_to_n.py"
          # Assuming you packaged and installed this globally as well
          # "niri-tile-to-n"
        ];

        xwayland-satellite.path = "xwayland-satellite";
      };
    };
  };
}
