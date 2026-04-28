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

       vim.lsp.servers.nixd.enable = true;
 
       vim.languages = {
       enableFormat = true;
       enableDAP = true;
       enableExtraDiagnostics = true;
       enableTreesitter = true;
       nix = {
         enable = true;
         format.enable = true;
         format.type = [ "nixfmt" ];


      };
     };
    };
   };
  };
 } 
                       
