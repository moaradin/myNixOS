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
        spawn-at-startup = [
          (lib.getExe self'.packages.myNoctalia)
        ];
        xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;
        input.keyboard.xkb.layout = "us";
        layout.gaps = 5;
        binds = {
          "Mod+Return".spawn-sh = lib.getExe pkgs.kitty;
          "Mod+Q".close-window = null;
          "Mod+S".spawn-sh = "${lib.getExe self'.packages.myNoctalia} ipc call launcher toggle";
        };
      };
    };
  };
}
