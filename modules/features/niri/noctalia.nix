{ self, inputs, ... }:
{
  flake.nixosModules.noctalia =
    { pkgs, ... }:
    {
      # Binary cache — avoids compiling Noctalia locally.
      # Only effective when inputs.nixpkgs.follows is omitted from the noctalia
      # flake input (see flake.nix).
      nix.settings = {
        extra-substituters = [ "https://noctalia.cachix.org" ];
        extra-trusted-public-keys = [ "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4=" ];
      };

      # Required by Noctalia for battery, power-profile, wifi, and bluetooth widgets.
      services.upower.enable = true;

      # Install the noctalia v5 package system-wide.
      # Configuration lives in ~/.config/noctalia/ and is owned entirely by the
      # app — there is no Nix-managed settings block here.  Use Noctalia's own
      # Settings UI (noctalia msg settings-toggle) to configure it, and the
      # resulting files will persist across reboots via the /home subvolume.
      environment.systemPackages = [
        inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };
}
