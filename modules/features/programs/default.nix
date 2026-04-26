{ self, inputs, ... }: {
  flake.nixosModules.programs = { ... }: {
    imports = [
      ./_ghostty.nix
    ];
  };
}
