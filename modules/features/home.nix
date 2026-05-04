{ self, inputs, ... }:
{

  flake.nixosModules.home =
    { pkgs, config, ... }:
    {
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
            equibop
            yazi
            helix
            thunderbird
            qbittorrent
            bitwarden-desktop
            mpv
            xdg-utils
            cliphist
            yt-dlp
            aria2
            inotify-tools
            yad
            inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
          ];

          programs.fish =
            let
              pluginList =
                plugins:
                map (plugin: {
                  name = "${plugin}";
                  src = pkgs.fishPlugins."${plugin}".src;
                }) plugins;
            in
            {
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

          home.sessionVariables = {
            EDITOR = "nvim";
            VISUAL = "nvim";
          };

          xdg.mimeApps = {
            enable = true;
            defaultApplications =
              let
                browser = [ "zen.desktop" ];
                filemanager = [ "org.gnome.Nautilus.desktop" ];
                texteditor = [ "org.gnome.TextEditor.desktop" ];
                video = [ "mpv.desktop" ];
                audio = [ "mpv.desktop" ];
                image = [ "org.gnome.Loupe.desktop" ];
                archive = [ "org.gnome.Nautilus.desktop" ];
                torrent = [ "org.qbittorrent.qBittorrent.desktop" ];
                mail = [ "thunderbird.desktop" ];
              in
              {
                # ── Browser ───────────────────────────────────────────────────────────
                "text/html" = browser;
                "application/xhtml+xml" = browser;
                "application/x-extension-htm" = browser;
                "application/x-extension-html" = browser;
                "application/x-extension-shtml" = browser;
                "application/x-extension-xhtml" = browser;
                "application/x-extension-xht" = browser;
                "x-scheme-handler/http" = browser;
                "x-scheme-handler/https" = browser;
                "x-scheme-handler/ftp" = browser;
                "x-scheme-handler/chrome" = browser;
                "x-scheme-handler/about" = browser;
                "x-scheme-handler/unknown" = browser;
                "x-scheme-handler/webcal" = browser;

                # ── App scheme handlers ───────────────────────────────────────────────
                "x-scheme-handler/discord" = [ "equibop.desktop" ];
                "x-scheme-handler/kdeconnect" = [ "org.kde.dolphin.desktop" ];
                "x-scheme-handler/magnet" = torrent;
                "x-scheme-handler/mailto" = mail;

                # ── File manager ──────────────────────────────────────────────────────
                "inode/directory" = filemanager;

                # ── Text / code ───────────────────────────────────────────────────────
                "text/plain" = texteditor;
                "text/markdown" = texteditor;
                "text/css" = texteditor;
                "text/javascript" = texteditor;
                "text/typescript" = texteditor;
                "text/x-python" = texteditor;
                "text/x-script.python" = texteditor;
                "text/x-shellscript" = texteditor;
                "text/x-csrc" = texteditor;
                "text/x-chdr" = texteditor;
                "text/x-c++src" = texteditor;
                "text/x-lua" = texteditor;
                "text/xml" = texteditor;
                "application/json" = texteditor;
                "application/xml" = texteditor;
                "application/x-shellscript" = texteditor;
                "application/x-yaml" = texteditor;
                "application/toml" = texteditor;

                # ── Subtitles ─────────────────────────────────────────────────────────
                "text/x-ssa" = texteditor; # ass/ssa
                "application/x-subrip" = texteditor; # srt

                # ── PDF ───────────────────────────────────────────────────────────────
                "application/pdf" = browser;

                # ── Archives ─────────────────────────────────────────────────────────
                "application/zip" = archive;
                "application/x-tar" = archive;
                "application/x-7z-compressed" = archive;
                "application/x-rar" = archive;
                "application/gzip" = archive;
                "application/zstd" = archive;

                # ── Torrents ──────────────────────────────────────────────────────────
                "application/x-bittorrent" = torrent;

                # ── Email ─────────────────────────────────────────────────────────────
                "message/rfc822" = mail;

                # ── Calendar ─────────────────────────────────────────────────────────
                "text/calendar" = mail;
                "application/ics" = mail;

                # ── Image ─────────────────────────────────────────────────────────────
                "image/jpeg" = image;
                "image/png" = image;
                "image/gif" = image;
                "image/webp" = image;
                "image/avif" = image;
                "image/heic" = image;
                "image/heif" = image;
                "image/tiff" = image;
                "image/bmp" = image;
                "image/x-bmp" = image;
                "image/vnd.microsoft.icon" = image; # ico
                "image/svg+xml" = image;

                # ── Video ─────────────────────────────────────────────────────────────
                "video/mp4" = video;
                "video/x-matroska" = video; # mkv
                "video/webm" = video;
                "video/avi" = video;
                "video/x-msvideo" = video; # avi (alt)
                "video/vnd.avi" = video; # avi (alt)
                "video/quicktime" = video; # mov
                "video/x-flv" = video;
                "video/mp2t" = video; # ts
                "video/mpeg" = video; # mpeg/mpg
                "video/ogg" = video; # ogv
                "video/x-ogm+ogg" = video;
                "video/3gpp" = video;
                "video/3gpp2" = video;
                "video/x-ms-wmv" = video;
                "video/x-ms-asf" = video;
                "video/dv" = video;
                "video/x-divx" = video;
                "video/x-xvid" = video;
                "video/H264" = video;
                "video/H265" = video;

                # ── Audio ─────────────────────────────────────────────────────────────
                "audio/mpeg" = audio; # mp3
                "audio/mp4" = audio; # m4a/aac
                "audio/aac" = audio;
                "audio/ogg" = audio;
                "audio/flac" = audio;
                "audio/x-flac" = audio;
                "audio/wav" = audio;
                "audio/x-wav" = audio;
                "audio/opus" = audio;
                "audio/webm" = audio;
                "audio/x-ms-wma" = audio;
                "audio/x-matroska" = audio; # mka
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

          imports = [
            ../../scripts/steam-wire.nix
            ../../scripts/zen-browser.nix
          ];

        };
      };
    };
}
