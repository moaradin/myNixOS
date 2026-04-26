# modules/features/programs/ghostty.nix
{ pkgs, ... }: 

{
  programs.ghostty = {
    enable = true;
    enableFishIntegration = true; 
    
    settings = {
      command = "${pkgs.fish}/bin/fish";
      theme = "noctalia";
      background-opacity = 0.80;
      clipboard-read = allow;
      clipboard-write = allow;
      copy-on-select = clipboard;
    };
  };
}
