{ self, inputs, ... }:
{
  flake.nixosModules.millennium =
    { pkgs, ... }:
    {
      nixpkgs.overlays = [ inputs.millennium.overlays.default ];

      # Replaces the stock steam package with the Millennium-injected one.
      # Works alongside your existing programs.steam config in gaming.nix —
      # just overrides the package, everything else stays untouched.
      programs.steam.package = pkgs.millennium-steam;
    };
}
