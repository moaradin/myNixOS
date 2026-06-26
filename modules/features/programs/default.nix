{ self, inputs, ... }: {
  flake.nixosModules.programs = { ... }: {
    imports = [
      # program file names need to start with an understore so import-tree doesn't pick it up
      ./_ghostty.nix
      ./_obs-studio.nix
      # ./_discord.nix
    ];
  };
}
