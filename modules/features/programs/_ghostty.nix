{ pkgs, ... }:
{
  home-manager.users.moara.programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      command = "${pkgs.fish}/bin/fish";
      theme = "Gruvbox Dark";
      background-opacity = 0.80;
      clipboard-read = "allow";
      clipboard-write = "allow";
      copy-on-select = "clipboard";
    };
  };
}
