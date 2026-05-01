# modules/features/winetricks-fix.nix
#
# Workaround for https://github.com/NixOS/nixpkgs/issues/338367
# (also: https://github.com/NixOS/nixpkgs/issues/503592)
#
# Applies the fix from the unmerged PR #431117:
#   https://github.com/NixOS/nixpkgs/pull/431117
#
# On NixOS, wine and wineserver are wrapper shell scripts, not ELF binaries.
# Winetricks tries to inspect the binary architecture of those files to detect
# WoW64 mode — which obviously fails for shell scripts, causing the
# "returned empty string" error and broken prefixes.
#
# The upstream winetricks fix (already in the 20260125 release you have)
# adds WINE_BIN / WINESERVER_BIN env vars so winetricks can be pointed at
# the real binaries.  The nixpkgs postInstall just needs to inject sensible
# defaults for those vars — that's the one line the unmerged PR adds.
#
# NOTE: if the patch _fails to apply_ during build, it means the upstream
# commit is already in your winetricks version (likely). In that case, remove
# the `patches` block entirely and keep only the postInstall addition.
{ self, inputs, ... }:
{
  flake.nixosModules.winetricksFix =
    { pkgs, ... }:
    {
      nixpkgs.overlays = [
        (final: prev: {
          winetricks = prev.winetricks.overrideAttrs (old: {

            # The upstream commit that adds WINE_BIN / WINESERVER_BIN support.
            # Remove this block if your winetricks build fails with a patch error
            # (it means 20260125 already includes it).


            # Inject NixOS-appropriate defaults right after the shebang line.
            # : "${VAR:=default}"  →  bash no-op that sets VAR only if unset/empty.
            # /run/current-system/sw/bin/.wine  is the real ELF binary;
            # /run/current-system/sw/bin/wine   is the NixOS wrapper script.
            postInstall = (old.postInstall or "") + ''
              sed -i \
                -e '2i : "''${WINESERVER_BIN:=/run/current-system/sw/bin/wineserver}"' \
                -e '2i : "''${WINE_BIN:=/run/current-system/sw/bin/.wine}"' \
                "$out/bin/winetricks"
            '';
          });
        })
      ];
    };
}
