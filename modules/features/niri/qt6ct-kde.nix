{ self, inputs, ... }:
{
  flake.nixosModules.qt6ct-kde =
    { ... }:
    {
      nixpkgs.overlays = [
        (final: prev: {
          kdePackages = prev.kdePackages.overrideScope (
            kfinal: kprev: {
              qt6ct = kprev.qt6ct.overrideAttrs (old: {
                pname = "qt6ct-kde";
                patches = (old.patches or [ ]) ++ [ ./scripts/qt6ct-kde.patch ];
                buildInputs = (old.buildInputs or [ ]) ++ [
                  kfinal.kconfig
                  kfinal.kcolorscheme
                  kfinal.kiconthemes
                ];
              });
            }
          );
        })
      ];
    };
}
