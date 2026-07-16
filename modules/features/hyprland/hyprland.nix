{ self, inputs, ... }:
{
  flake.nixosModules.hyprland =
    { pkgs, lib, ... }:
    {

      # Enables critical components needed to run Hyprland properly
      programs.hyprland = {
        enable = true;
        withUWSM = true;
        xwayland.enable = true;
      };

      # ── Session ───────────────────────────────────────────────────────────

      services.greetd = {
        enable = true;
        settings.default_session = {
          command = "uwsm start hyprland-uwsm.desktop";
          user = "moara";
        };
      };

      # ── Home User Settings ────────────────────────────────────────────────

      home-manager.users.moara =
        { config, ... }:
        {

          home.pointerCursor = {
            enable = true;
            name = "Bibata-Modern-Ice";
            package = pkgs.bibata-cursors;
            size = 24;
            gtk.enable = true;
            x11.enable = true;
          };

          gtk = {
            enable = true;
            iconTheme = {
              name = "Gruvbox-Plus-Dark";
              package = pkgs.gruvbox-plus-icons;
            };
            theme = {
              name = "gruvbox-dark";
              package = pkgs.gruvbox-dark-gtk;
            };
            gtk4.theme = null;
          };

          qt = {
            enable = true;
            # platformTheme.name = "kvantum";
            # style.name = "kvantum";
          };

          services.gnome-keyring = {
            enable = true;
            components = [
              "pkcs11"
              "secrets"
              "ssh"
            ];
          };

          services.kdeconnect.enable = true;

          xdg.userDirs = {
            enable = true;
            createDirectories = true;
            setSessionVariables = false;
            desktop = "/home/moara/Desktop";
            documents = "/home/moara/Documents";
            download = "/home/moara/Downloads";
            music = "/home/moara/Music";
            pictures = "/home/moara/Pictures";
            publicShare = "/home/moara/Public";
            templates = "/home/moara/Templates";
            videos = "/home/moara/Videos";
          };

        };

      # ── Firewall Settings ────────────────────────────────────────────────
      networking.firewall = rec {
        allowedTCPPortRanges = [
          {
            from = 1714;
            to = 1764;
          }
        ];
        allowedUDPPortRanges = allowedTCPPortRanges;
      };

      # ── System services ───────────────────────────────────────────────────

      services.gvfs.enable = true;

      # gnome-keyring for greetd/noctalia-greeter
      security.pam.services.greetd.enableGnomeKeyring = true;

      gtk.iconCache.enable = true;
      xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

      # ── System packages ───────────────────────────────────────────────────

      environment.systemPackages = with pkgs; [
        kitty # Required for the default Hyprland config

        # General System Packages
        xdg-utils
        seahorse
        wl-clipboard
        nautilus
        sushi
        file-roller
        loupe
        gnome-calculator
        gnome-text-editor
        kdePackages.qt6ct
        kdePackages.breeze
        kdePackages.dolphin
        ffmpegthumbnailer
        resources
        libnotify
        playerctl
      ];

      # ── Environment Variables ─────────────────────────────────────────────
      environment.sessionVariables = {
        NIXOS_OZONE_WL = "1";
      };

    };
}
