{ self, inputs, ... }: {
  flake.nixosModules.nvf = {pkgs, ...}: {
    imports = [
      inputs.nvf.nixosModules.default # Provides programs.nvf.*
    ];

    programs.nvf = {
      enable = true;
      settings = {
      
        vim.theme = {
          enable = true;
          name = "gruvbox";
          style = "dark";
          transparent = true;
       };
       
       vim.languages = {
        nix.enable = true;
      };
     };
    };
   };
  } 
