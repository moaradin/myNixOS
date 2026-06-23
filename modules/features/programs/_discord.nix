{ config, pkgs, ... }:
{
  home-manager.users.moara = {

    # Discord with Equicord injected via override
    home.packages = with pkgs; [
      (discord.override {
        withVencord = true;

        # Inject Equicord and apply the patcher.js symlink workaround
        vencord = equicord.overrideAttrs (old: {
          postInstall = (old.postInstall or "") + ''
            if [ ! -f $out/patcher.js ]; then
              find $out -name "patcher.js" -exec ln -s {} $out/patcher.js \;
            fi
          '';
        });
      })
    ];

  };
}
