{ self, inputs, ... }: {

  flake.nixosModules.home = { pkgs, config, ... }: {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      
      # Passes flake inputs to Home Manager, useful if you install packages like zen-browser via HM later
      extraSpecialArgs = { inherit self inputs; };
      
      users.moara = {
      
imports = let
          programDir = ./programs;
          files = builtins.attrNames (builtins.readDir programDir);
        in
          map (file: import (programDir + "/${file}") { inherit pkgs; }) files;
      
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
