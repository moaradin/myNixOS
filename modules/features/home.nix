{ self, inputs, ... }: {

  flake.nixosModules.home = { pkgs, config, ... }: {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      
      # Passes flake inputs to Home Manager, useful if you install packages like zen-browser via HM later
      extraSpecialArgs = { inherit self inputs; };
      
      users.moara = {
        # Must match the stateVersion in your configuration.nix
        home.stateVersion = "25.11"; 
        
        home.packages = with pkgs; [
          yazi
          # Provides the hx command for your text editor workflow
          tree
          firefox
	  vesktop
	  yazi
	  helix
	  thunderbird
	  qbittorrent
	  bitwarden-desktop
	  mpv
	  yt-dlp
          fishPlugins.hydro
          fishPlugins.done
          fishPlugins.autopair
          fishPlugins.forgit
          fishPlugins.grc
          fishPlugins.fzf-fish
          fishPlugins.z
          inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];
        
        gtk.enable = true;
        gtk.cursorTheme.name = "Bibata-Modern-Ice";
        gtk.icontheme.name = "GruvboxPlus";
        
        programs.fish = {
          enable = true;
          interactiveShellInit = ''
           set -g fish_greeting
           
           fastfetch
         '';
        }; 
        
        programs.ghostty = {
          enable = true;
    
          # Automatically injects Ghostty's shell integration scripts for Fish
          enableFishIntegration = true; 
    
          settings = {
          # Tells Ghostty to launch Fish instead of the system default shell (Bash)
          command = "${pkgs.fish}/bin/fish";
          theme = "noctalia";
      
          # You can add the rest of your Ghostty configuration here
          # For example:
          # theme = "catppuccin-mocha";
          # font-family = "FiraCode Nerd Font";
         };
        };

        # Example: You can optionally move your Git config here from configuration.nix
         programs.git = {
           enable = true;
           settings = {
             user = {
               name = "moara";
               email = "8263241+moaradin@users.noreply.github.com";
            };
          };
        }; 
      };
    };
  };
}
