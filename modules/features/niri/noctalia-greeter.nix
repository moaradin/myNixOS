{ self, inputs, ... }:
{
  flake.nixosModules.noctalia-greeter =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      imports = [
        inputs.noctalia-greeter.nixosModules.default
      ];

      programs.noctalia-greeter = {
        enable = true;
        # Optional: Set the default Wayland session
        # greeterArgs = [ "--session" "niri" ];
      };
    };
}
