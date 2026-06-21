{ self, inputs, ... }:
{

  flake.nixosModules.myMachineConfiguration =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {

      imports = [
        self.nixosModules.myMachineHardware # hardware-configuration
        self.nixosModules.myMachineDisko # disk layout (tmpfs root + subvolumes)
        self.nixosModules.preservation # impermanence — bind-mounts /persistent paths
        self.nixosModules.zram
        self.nixosModules.niri
        self.nixosModules.noctalia
        self.nixosModules.qt6ct-kde
        #self.nixosModules.noctalia-greeter
        self.nixosModules.nvidia
        self.nixosModules.gaming
        self.nixosModules.mounts
        self.nixosModules.cachyos
        self.nixosModules.home
        self.nixosModules.nvf
        self.nixosModules.programs
      ];

      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.loader.systemd-boot.configurationLimit = 10;
      #Regular Kernel. Disable when using CachyOS
      #boot.kernelPackages = pkgs.linuxPackages_latest;

      boot.tmp.cleanOnBoot = true;

      systemd.services.systemd-machine-id-commit.enable = false;

      networking.hostName = "myMachine";
      networking.networkmanager.enable = true;

      hardware.bluetooth.enable = true;

      services.power-profiles-daemon.enable = true;

      custom.zram.enable = true;

      time.timeZone = "America/New_York";
      time.hardwareClockInLocalTime = true;

      i18n.defaultLocale = "en_US.UTF-8";
      console = {
        font = "Lat2-Terminus16";
        keyMap = "us";
        packages = with pkgs; [
          terminus_font
        ];
      };

      # Temp permission for Bitwarden
      nixpkgs.config.permittedInsecurePackages = [
        "electron-39.8.10"
      ];

      # Flatpak
      services.flatpak.enable = true;

      programs.nh = {
        enable = true;
        clean.enable = true;
        clean.extraArgs = "--keep 5";
        flake = "/home/moara/myNixOS"; # sets NH_OS_FLAKE variable for you
      };

      # Appimages

      programs.appimage = {
        enable = true;
        binfmt = true;
        package = pkgs.appimage-run.override {
          extraPkgs =
            pkgs: with pkgs; [
              zstd # libzstd.so.1
              libxshmfence # libxshmfence.so.1
              libxkbfile # libxkbfile.so.1   ← current crash
              libxkbcommon # libxkbcommon.so.0, libxkbcommon-x11.so.0
              libdrm # libdrm.so.2
              mesa # libgbm.so.1
              wayland # libwayland-client/cursor/egl.so.*
              xcbutilcursor # libxcb-cursor.so.0
              libglvnd
            ];
        };
      };

      # Gnome Desktop
      #services.displayManager.gdm.enable = true;
      #services.desktopManager.gnome.enable = true;

      #SDDM
      # services.displayManager.sddm = {
      #   enable = true;
      #   wayland  = {
      #     enable = true;
      #    };
      # };

      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };

      users.users.root.hashedPassword = "$y$j9T$vtypyDI1x4mCTWkrPgG8U.$o7be8PQf4u3/6f2VWAbyaY1aRfMmqgK6Cpe4.Gey2b2";

      users.users.moara = {
        isNormalUser = true;
        hashedPassword = "$y$j9T$vtypyDI1x4mCTWkrPgG8U.$o7be8PQf4u3/6f2VWAbyaY1aRfMmqgK6Cpe4.Gey2b2";
        extraGroups = [
          "wheel"
          "networkmanager"
          "gamemode"
          "input"
          "uinput"
        ];
      };

      environment.systemPackages = with pkgs; [
        go
        jq
        git
        sshfs
        fuse
        inxi
        glib
        pciutils
        lsof
        wayland-utils
        wlr-randr
        wmctrl
        xdpyinfo
        xprop
        xdriinfo
        xrandr
        python3
        fastfetch
        wget
        unzip
        unrar
        btop
        duf
        plocate
        ripgrep
        zoxide
        fd
        nixd
        nix-output-monitor
        nvd
        lazygit
        grc
        fzf
        eza
        bat
        bat-extras.batgrep
        bat-extras.batman
        copycat
        tealdeer
        evtest

        # Gstreamer
        gst_all_1.gstreamer
        gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-good
        gst_all_1.gst-plugins-bad
        gst_all_1.gst-plugins-ugly
        gst_all_1.gst-libav
        gst_all_1.gst-vaapi
      ];

      environment.variables = {
        GST_PLUGIN_PATH = "/run/current-system/sw/lib/gstreamer-1.0/";
      };

      fonts = {
        enableDefaultPackages = true;
        packages = with pkgs; [
          noto-fonts
          jetbrains-mono
          nerd-fonts.jetbrains-mono
        ];
        fontconfig = {
          enable = true;
          defaultFonts = {
            serif = [ "JetBrains Mono" ];
            sansSerif = [ "JetBrains Mono" ];
            monospace = [ "JetBrains Mono" ];
            emoji = [ "Noto Color Emoji" ];
          };
        };
      };

      services.openssh.enable = true;

      nixpkgs.config.allowUnfree = true;
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      nix.settings = {
        substituters = [
          "https://attic.xuyh0120.win/lantian"
          "https://cache.nixos.org"
        ];
        trusted-public-keys = [
          "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        ];
      };

      system.stateVersion = "25.11";
    };

}
