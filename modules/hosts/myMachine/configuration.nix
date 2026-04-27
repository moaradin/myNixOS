{ self, inputs, ... }: {

  flake.nixosModules.myMachineConfiguration = { pkgs, lib, config, ... }: {

    imports = [
      self.nixosModules.myMachineHardware   # was ./hardware-configuration.nix
      self.nixosModules.myMachineDisko      # was ./disk-config.nix
      self.nixosModules.zram                # was ./zram.nix
      self.nixosModules.niri
      self.nixosModules.noctalia
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
    
    networking.hostName = "myMachine";
    networking.networkmanager.enable = true;

    custom.zram.enable = true;

    time.timeZone = "America/New_York";

    i18n.defaultLocale = "en_US.UTF-8";
    console = {
      font = "Lat2-Terminus16";
      keyMap = "us";
      packages = with pkgs; [
        terminus_font
       ]; 
    };
      
      # Flatpak
      services.flatpak.enable = true;
      
      programs.nh = {
        enable = true;
        clean.enable = true;
        clean.extraArgs = "--keep 10";
        flake = "/home/moara/myNixOS"; # sets NH_OS_FLAKE variable for you
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

    users.users.moara = {
      isNormalUser = true;
      initialHashedPassword = "$y$j9T$ehIFnAgbxYtk19FXvbEgo/$OP7Hd8L22rUf2MShZ0IhrpiqX26rgpJ8L9zNkXtuVF4";
      extraGroups = [ "wheel" "networkmanager" "gamemode" ];
    };

    environment.systemPackages = with pkgs; [
      go
      jq
      git
      sshfs
      fuse3
      inxi
      pciutils
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
      lazygit
      grc
      fzf
      eza
      bat
      bat-extras.batgrep
      bat-extras.batman
      copycat
      tealdeer
      
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
          serif      = [ "JetBrains Mono" ];
          sansSerif  = [ "JetBrains Mono" ];
          monospace  = [ "JetBrains Mono" ];
          emoji      = [ "Noto Color Emoji" ];
        };
      };
    };
    
    services.openssh.enable = true;

    nixpkgs.config.allowUnfree = true;
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    
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
