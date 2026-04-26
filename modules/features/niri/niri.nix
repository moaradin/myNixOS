{ self, inputs, ... }: {
  flake.nixosModules.niri = { pkgs, lib, ... }: {

    imports = [
      inputs.niri-flake.nixosModules.niri  # handles portals, polkit, keyring, session
    ];

    programs.niri.enable = true;

    # Point niri at the plain KDL file sitting next to this module.
    # niri-flake will still run `niri validate` against it at build time,
    # so broken configs are caught before you switch — but you edit plain KDL.
    home-manager.users.moara.programs.niri.config = ./config.kdl;

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
    };

    # ── System services ───────────────────────────────────────────────────

    services.gvfs.enable = true;
    # gnome-keyring is handled automatically by niri-flake — not needed here

    gtk.iconCache.enable = true;
    # niri-flake installs xdg-desktop-portal-gnome for screencasting.
    # xdg-desktop-portal-gtk is a separate addition for GTK file pickers.
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

    # ── System packages ───────────────────────────────────────────────────

    environment.systemPackages = with pkgs; [
      seahorse
      wl-clipboard
      nautilus
      gnome-text-editor
      kdePackages.qt6ct
      ffmpegthumbnailer
      gnome-system-monitor
      libnotify       # notify-send (used by Mod+Alt+W wallpaper bind)
      playerctl       # media key binds
    ];
  };
}
