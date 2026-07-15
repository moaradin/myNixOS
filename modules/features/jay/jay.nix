{ self, inputs, ... }:
{
  flake.nixosModules.jay =
    { pkgs, lib, ... }:
    let
      # Option A: Perform direct source substitution during the build phase.
      # This approach is fully self-contained and immune to copy-paste whitespace corruption.
      patchedJay = inputs.jay.packages.${pkgs.system}.default.overrideAttrs (oldAttrs: {
        postPatch = (oldAttrs.postPatch or "") + ''
          substituteInPlace src/ifs/wl_surface/zwlr_layer_surface_v1.rs \
            --replace-fail '        if anchor == 0 {
                      anchor = LEFT | RIGHT | TOP | BOTTOM;' '        if anchor & (LEFT | RIGHT) == 0 {
                      anchor |= LEFT | RIGHT;
                  }
                  if anchor & (TOP | BOTTOM) == 0 {
                      anchor |= TOP | BOTTOM;'
        '';
      });
    in
    {
      # Bring in the native module options from the Jay flake
      imports = [ inputs.jay.nixosModules.default ];

      programs.jay.enable = true;
      programs.jay.package = patchedJay; # Enforce the use of our modified package

      # ── Session ───────────────────────────────────────────────────────────
      # Disable when using Noctalia Greeter
      services.greetd = {
        enable = true;
        settings.default_session = {
          command = "jay run";
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

          # The niri-screenshot package was removed.
          # Use `jay msg screenshot` in your jay configuration instead.
          home.packages = [ ];

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
      xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

      # ── System packages ───────────────────────────────────────────────────

      environment.systemPackages = with pkgs; [
        xwayland-satellite
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

    };
}
