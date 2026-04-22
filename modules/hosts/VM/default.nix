{ self, inputs, ... }: {

  flake.nixosConfigurations.VM = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.VMConfiguration
    ];
   };
}
