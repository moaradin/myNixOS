{ self, inputs, ... }: {
  flake.nixosModules.noctalia = { pkgs, ... }: {

    # Binary cache — avoids compiling Quickshell locally
    nix.settings = {
      extra-substituters       = [ "https://noctalia.cachix.org" ];
      extra-trusted-public-keys = [ "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4=" ];
    };

    home-manager.users.moara = {
      imports = [ inputs.noctalia.homeModules.default ];

      programs.noctalia-shell = {
        enable = true;
        # noctalia.json has an outer { "settings": { ... } } wrapper,
        # so we extract .settings exactly like the old wrapper-modules did.
        settings = (builtins.fromJSON (builtins.readFile ./noctalia.json)).settings;
      };
    };
  };
}
