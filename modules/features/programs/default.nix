{ self, inputs, ... }: {
  flake.nixosModules.programs = { ... }: {
    imports = [
      ./_ghostty.nix
      ./_obs-studio.nix
    ];
  };
}
