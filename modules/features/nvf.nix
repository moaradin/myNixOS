{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.nvf = {pkgs, ...}: {
    imports = [
      inputs.nvf.nixosModules.default # Provides programs.nvf.*
    ];

    programs.nvf = {
      enable = true;
      settings = {
        vim.theme.enable = true;
        vim.theme.name = "gruvbox";
        vim.theme.style = "dark";

        vim.languages.nix.enable = true;
      };
    };
  };
}
