{ self, inputs, ... }: {
  flake.nixosModules.niri = { pkgs, lib, ... }: {

    imports = [
      inputs.niri-flake.nixosModules.niri  # handles portals, polkit, keyring, session
    ];

    # niri-flake's overlay exposes pkgs.niri-stable and pkgs.niri-unstable.
    # niri-unstable tracks the latest commit to niri's main branch.
    nixpkgs.overlays = [ inputs.niri-flake.overlays.niri ];

    programs.niri.enable = true;
    programs.niri.package = pkgs.niri-unstable;


    # ── Session ───────────────────────────────────────────────────────────

    services.greetd = {
      enable = true;
      settings.default_session = {
        command = "niri-session";
        user = "moara";
      };
    };

    # ── Home User Settings ────────────────────────────────────────────────

    home-manager.users.moara = {
     
      xdg.configFile."niri/config.kdl".text = builtins.readFile ./config.kdl;
     
      home.pointerCursor = {
        name    = "Bibata-Modern-Ice";
        package = pkgs.bibata-cursors;
        size    = 24;
        gtk.enable = true;
        x11.enable  = true;
      };

      gtk = {
        enable = true;
        iconTheme = {
          name    = "Papirus";
          package = pkgs.papirus-icon-theme;
        };
        theme = {
          name    = "adw-gtk3";
          package = pkgs.adw-gtk3;
        };
        gtk4.theme = null;
      };
      
     qt = {
       enable = true;
       platformTheme.name = "kvantum";
       style.name = "kvantum";
     };
      
      services.gnome-keyring = {
        enable = true;
        components = [ "pkcs11" "secrets" "ssh" ];
      };
      
      services.kdeconnect.enable = true;
      
      xdg.userDirs = {
        enable = true;
        createDirectories = true;
        setSessionVariables = false;
        desktop     = "/home/moara/Desktop";
        documents   = "/home/moara/Documents";
        download    = "/home/moara/Downloads";
        music       = "/home/moara/Music";
        pictures    = "/home/moara/Pictures";
        publicShare = "/home/moara/Public";
        templates   = "/home/moara/Templates";
        videos      = "/home/moara/Videos";
      };

    };
    
    # ── Firewall Settings ────────────────────────────────────────────────    
      networking.firewall = rec {
        allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
        allowedUDPPortRanges = allowedTCPPortRanges;
      };

    # ── System services ───────────────────────────────────────────────────

    services.gvfs.enable = true;
    
    # gnome-keyring for greetd
     security.pam.services.greetd.enableGnomeKeyring = true;

    gtk.iconCache.enable = true;
    # niri-flake installs xdg-desktop-portal-gnome for screencasting.
    # xdg-desktop-portal-gtk is a separate addition for GTK file pickers.
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

    # ── System packages ───────────────────────────────────────────────────

    environment.systemPackages = with pkgs; [
      xwayland-satellite
      seahorse
      wl-clipboard
      nautilus
      loupe
      gnome-text-editor
      kdePackages.qt6ct
      kdePackages.dolphin
      ffmpegthumbnailer
      gnome-system-monitor
      gruvbox-kvantum
      kvmarwaita
      libnotify       # notify-send (used by Mod+Alt+W wallpaper bind)
      playerctl       # media key binds
    ];
  };
}
