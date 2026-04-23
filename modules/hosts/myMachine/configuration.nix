{ self, inputs, ... }: {

  flake.nixosModules.myMachineConfiguration = { pkgs, lib, config, ... }: {

    imports = [
      self.nixosModules.myMachineHardware   # was ./hardware-configuration.nix
      self.nixosModules.myMachineDisko      # was ./disk-config.nix
      self.nixosModules.zram                # was ./zram.nix
      self.nixosModules.niri
      self.nixosModules.nvidia
      self.nixosModules.gaming
      self.nixosModules.mounts
      #self.nixosModules.cachyos
      
    ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.kernelPackages = pkgs.linuxPackages_latest;

    networking.hostName = "myMachine";
    networking.networkmanager.enable = true;

    custom.zram.enable = true;

    time.timeZone = "America/New_York";

    i18n.defaultLocale = "en_US.UTF-8";
    console = {
      font = "Lat2-Terminus16";
      keyMap = "us";
    };

    programs.fish = {
      enable = true;
      interactiveShellInit = ''set fish_greeting'';
    };

    programs.git = {
      enable = true;
      config = {
        user.name = "moara";
        user.email = "8263241+moaradin@users.noreply.github.com";
        };
      };
      
      # Flatpak
      services.flatpak.enable = true;



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
      shell = pkgs.fish;
      initialHashedPassword = "$y$j9T$ehIFnAgbxYtk19FXvbEgo/$OP7Hd8L22rUf2MShZ0IhrpiqX26rgpJ8L9zNkXtuVF4";
      extraGroups = [ "wheel" "networkmanager" "gamemode" ];
      packages = with pkgs; [
        tree
        firefox
	equibop
	yazi
	helix
	thunderbird
	qbittorrent
	bitwarden-desktop
	mpv
	yt-dlp
        inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default


      ];
    };

    environment.systemPackages = with pkgs; [
      neovim
      git
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
      cliphist
      ghostty
      
      #Gnome Extensions
      #gnomeExtensions.blur-my-shell
      #gnomeExtensions.just-perfection
      #gnomeExtensions.arc-menu
      #gnomeExtensions.dash-to-panel
      #gnomeExtensions.clipboard-indicator
      #gnomeExtensions.appindicator
      
      fishPlugins.hydro
      fishPlugins.done
      fishPlugins.autopair
      fishPlugins.forgit
      fishPlugins.grc
      fishPlugins.fzf-fish
      fishPlugins.z
      grc
      fzf
      
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
