{ pkgs, ... }:
{
  # Forcefully overwrite the file, ignoring existing backups
  home-manager.users.moara.xdg.configFile."ghostty/config".force = true;

  home-manager.users.moara.programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      command = "${pkgs.fish}/bin/fish";
      theme = "Gruvbox Dark";
      background-opacity = 0.80;
      background-blur-radius = 20;
      clipboard-read = "allow";
      clipboard-write = "allow";
      copy-on-select = "clipboard";
    };
  };
}
