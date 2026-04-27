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

    # ── Cursor & GTK theme ────────────────────────────────────────────────

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
      
      services.gnome-keyring = {
        enable = true;
        components = [ "pkcs11" "secrets" "ssh" ];
      };
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
      gnome-text-editor
      kdePackages.qt6ct
      ffmpegthumbnailer
      gnome-system-monitor
      libnotify       # notify-send (used by Mod+Alt+W wallpaper bind)
      playerctl       # media key binds
      kdePackages.kdeconnect-kde
    ];
  };
}
