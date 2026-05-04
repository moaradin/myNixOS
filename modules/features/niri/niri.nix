{ self, inputs, ... }:
{
  flake.nixosModules.niri =
    { pkgs, lib, ... }:
    {

      programs.niri.enable = true;

      # ── Session ───────────────────────────────────────────────────────────

      services.greetd = {
        enable = true;
        settings.default_session = {
          command = "niri-session";
          user = "moara";
        };
      };

      # ── Home User Settings ────────────────────────────────────────────────

      home-manager.users.moara =
        { config, ... }:
        let
          niri-screenshot = pkgs.writeShellApplication {
            name = "niri-screenshot";
            runtimeInputs = [
              pkgs.jq
              pkgs.niri
            ];
            text = builtins.readFile ./scripts/niri-screenshot.sh;
          };
        in
        {

          # xdg.configFile."niri/config.kdl".text =
          #builtins.replaceStrings
          #   [ "spawn \"niri-screenshot\"" ]
          #   [ "spawn \"${niri-screenshot}/bin/niri-screenshot\"" ]
          #   (builtins.readFile ./config.kdl);

          # home.pointerCursor = {
          #   name = "Bibata-Modern-Ice";
          #   package = pkgs.bibata-cursors;
          #   size = 24;
          #   gtk.enable = true;
          #   x11.enable = true;
          # };

          home.pointerCursor = {
            name = "Capitaine Cursors (Gruvbox) - White";
            package = pkgs.capitaine-cursors-themed;
            size = 22;
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
            platformTheme.name = "kvantum";
            style.name = "kvantum";
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

          home.packages = [ niri-screenshot ];

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
        libnotify # notify-send (used by Mod+Alt+W wallpaper bind)
        playerctl # media key binds
      ];

    };
}
