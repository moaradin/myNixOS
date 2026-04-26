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
	  xdg-utils
	  cliphist
	  yt-dlp
          inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];
        
        programs.fish = let
        pluginList = plugins: map (plugin: {
          name = "${plugin}";
          src = pkgs.fishPlugins."${plugin}".src;
        }) plugins;
      in {
        enable = true;
        
        interactiveShellInit = ''
          # Clears the greeting
          set -g fish_greeting 
          set -gx sponge_purge_only_on_exit true
          
          # Keep your fastfetch startup!
          fastfetch
        '';

        shellAbbrs = {
          ff = "fastfetch";
          lg = "lazygit";
        };

        shellAliases = {
          cat = "bat";
          man = "batman";
          shx = "sudo hx";
          mkdir = "mkdir -pv";
          cp = "rsync -ah --info=progress2";
          ls = "eza --all --group-directories-first --git --color=always --icons=always";
          ll = "eza -l --all --group-directories-first --git --color=always --icons=always";
          lt = "eza --tree --level 3 --git-ignore";
          fzf = "fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'";
        };

        functions = {
          copycat = "cat $argv | wl-copy";
        };

        plugins = pluginList [
          "autopair"
          "done"
          "puffer"
          "hydro"
          "sponge"
          "fzf-fish"
          "z"
          "grc"
          "forgit"
          "plugin-sudope"
        ];
      };
        
        programs.ghostty = {
          enable = true;
    
          # Automatically injects Ghostty's shell integration scripts for Fish
          enableFishIntegration = true; 
    
          settings = {
          # Tells Ghostty to launch Fish instead of the system default shell (Bash)
          command = "${pkgs.fish}/bin/fish";
          theme = "noctalia";
          background-opacity = 0.80;
          clipboard-read = "allow";
          clipboard-write = "allow";
          copy-on-select = "clipboard";
      
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
