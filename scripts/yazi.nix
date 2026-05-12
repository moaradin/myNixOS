# scripts/yazi.nix
#
# Yazi file manager — Home Manager configuration
# Imported inside home-manager.users.moara in modules/features/home.nix:
#
#   imports = [
#     ...
#     ../../scripts/yazi.nix
#   ];
#
# NOTE: After adding this, remove `yazi` from home.packages in home.nix
# (programs.yazi.enable installs it), and remove the `y = "yazi"` shellAbbr
# from programs.fish.shellAbbrs — shellWrapperName = "y" below replaces it
# with a proper wrapper that cds into yazi's last directory on exit.
#
# Plugins (all sourced from pkgs.yaziPlugins):
#   bookmarks, bypass, chmod, full-border, lazygit, jump-to-char,
#   ouch, recycle-bin, rich-preview, smart-enter, smart-filter, wl-clipboard
#
# If any plugin is missing from your nixpkgs snapshot, swap its entry for:
#   plugin-name = pkgs.fetchFromGitHub {
#     owner = "…"; repo = "…"; rev = "…"; hash = "…";
#   };

{ pkgs, ... }:
{
  # ── Runtime deps for plugins ───────────────────────────────────────────────
  # ouch   — needed by the ouch plugin for archive extraction/compression
  # python3Packages.rich — needed by rich-preview
  # lazygit — needed by the lazygit plugin (already in your system packages,
  #            but listed here so this module is self-contained)
  home.packages = with pkgs; [
    ouch
    lazygit
    (python3.withPackages (ps: [ ps.rich ]))
  ];

  programs.yazi = {
    enable = true;

    # ── RAR support ────────────────────────────────────────────────────────
    # Overrides the bundled 7zz with the unfree rar-capable variant.
    # nixpkgs.config.allowUnfree = true is already set in your config.
    package = pkgs.yazi.override { _7zz = pkgs._7zz-rar; };

    # ── Shell wrapper ──────────────────────────────────────────────────────
    # Creates a fish function `y` that automatically cds into yazi's last
    # working directory when you press q to quit. Much nicer than a plain alias.
    # Remove the `y = "yazi"` abbr from home.nix → programs.fish.shellAbbrs.
    shellWrapperName = "y";

    # ── Plugins ────────────────────────────────────────────────────────────
    plugins = with pkgs.yaziPlugins; {
      inherit
        bookmarks    # Persistent bookmarks across sessions
        bypass       # Bypass trash / confirmation on delete
        chmod        # Change file permissions interactively
        full-border  # Full-UI border decoration
        jump-to-char # vi-style f-jump within the file list
        lazygit      # Embedded lazygit pane
        ouch         # Archive extraction/compression via ouch
        recycle-bin  # Send to trash instead of permanent delete
        rich-preview # Richer previews using Python rich
        smart-enter  # Enter dirs OR open files with one key
        smart-filter # Interactive filter that stays visible
        wl-clipboard # Copy file paths/content to Wayland clipboard
        ;
    };

    # ── yazi.toml ──────────────────────────────────────────────────────────
    settings = {
      manager = {
        # Sort newest-modified first; directories always float to the top
        sort_by        = "modified";
        sort_sensitive = false;  # case-insensitive sorting
        sort_reverse   = true;   # newest first
        sort_dir_first = true;

        show_hidden  = true;     # show dotfiles
        show_symlink = true;     # show symlink targets in status bar

        # Panel width ratio: parent | current | preview
        ratio = [ 1 4 3 ];
      };

      preview = {
        image_filter  = "lanczos3"; # high-quality image downscaling
        image_quality = 90;
        tab_size      = 2;
        max_width     = 600;
        max_height    = 900;
      };

      tasks = {
        micro_workers = 5;
        macro_workers = 10;
        bizarre_retry = 5;
      };

      # ── Opener rules ─────────────────────────────────────────────────────
      # Mirrors your xdg.mimeApps defaults so yazi uses the same apps.
      opener = {
        image   = [{ run = "loupe \"$@\"";                 orphan = true; }];
        video   = [{ run = "mpv \"$@\"";                   orphan = true; }];
        audio   = [{ run = "mpv \"$@\"";                   orphan = true; }];
        pdf     = [{ run = "zen \"$@\"";                   orphan = true; }];
        archive = [{ run = "file-roller \"$@\"";           orphan = true; }];
        text    = [{ run = "ghostty -e nvim \"$@\"";       block  = true; }];
        fallback = [{ run = "xdg-open \"$@\"";             orphan = true; }];
      };
    };

    # ── init.lua ───────────────────────────────────────────────────────────
    # Loaded once at startup. Plugins that need setup() go here.
    initLua = /* lua */ ''
      -- Full-border: wraps the entire panel UI in a visible border
      require("full-border"):setup()

      -- Bookmarks: persist bookmarks to disk across sessions
      require("bookmarks"):setup({
        persist      = "all",   -- "all" | "none" | a path string
        notify       = true,    -- show a notification on save/jump
        sort_by      = "time_added",
        sort_reverse = false,
      })

      -- Rich-preview: use Python rich for prettier text/code previews
      require("rich-preview"):setup({
        mime_types = true,   -- infer type from mime rather than extension
      })
    '';

    # ── keymap.toml ────────────────────────────────────────────────────────
    # prepend_keymap runs before yazi's built-in binds, so these take priority.
    # Uncomment / adjust to taste.
    keymap = {
      manager.prepend_keymap = [

        # ── smart-enter: l / <Enter> / <Right> ───────────────────────────
        # Enters directories OR opens files — replaces the default two-step.
        { on = [ "l" ];        run = "plugin smart-enter"; desc = "Enter dir or open file"; }
        { on = [ "<Enter>" ];  run = "plugin smart-enter"; desc = "Enter dir or open file"; }
        { on = [ "<Right>" ];  run = "plugin smart-enter"; desc = "Enter dir or open file"; }

        # ── smart-filter: F ───────────────────────────────────────────────
        # Persistent filter bar — stays open while you type.
        { on = [ "F" ];        run = "plugin smart-filter"; desc = "Smart filter"; }

        # ── jump-to-char: f ───────────────────────────────────────────────
        # Press f then a character to jump to the next entry starting with it.
        # (Replaces the built-in filter-prefix on f — use F for that instead.)
        { on = [ "f" ];        run = "plugin jump-to-char"; desc = "Jump to char"; }

        # ── bookmarks ────────────────────────────────────────────────────
        { on = [ "b" ];        run = "plugin bookmarks --args=save";   desc = "Bookmark: save"; }
        { on = [ "B" ];        run = "plugin bookmarks --args=jump";   desc = "Bookmark: jump"; }
        { on = [ "<C-b>" ];    run = "plugin bookmarks --args=delete"; desc = "Bookmark: delete"; }

        # ── lazygit ──────────────────────────────────────────────────────
        # Opens a full lazygit pane inside yazi.
        { on = [ "<C-g>" ];    run = "plugin lazygit"; desc = "Open lazygit"; }

        # ── chmod ────────────────────────────────────────────────────────
        # Interactive permission editor for selected file(s).
        { on = [ "=" ];        run = "plugin chmod"; desc = "chmod selected"; }

        # ── recycle-bin & bypass ─────────────────────────────────────────
        # dd  → trash (recoverable)
        # dD  → permanent delete (built-in remove)
        # D   → bypass plugin: permanent delete without confirmation prompt
        { on = [ "d" "d" ];    run = "plugin recycle-bin"; desc = "Move to trash"; }
        { on = [ "d" "D" ];    run = "remove";             desc = "Delete permanently"; }
        { on = [ "D" ];        run = "plugin bypass";      desc = "Delete (skip confirm)"; }

        # ── ouch ─────────────────────────────────────────────────────────
        # Extract or compress using the ouch CLI.
        # <C-o> → extract the selected archive into the current directory
        # <C-e> → compress the selected files (ouch will prompt for output name)
        { on = [ "<C-o>" ];    run = "plugin ouch --args=extract";  desc = "Extract with ouch"; }
        { on = [ "<C-e>" ];    run = "plugin ouch --args=compress"; desc = "Compress with ouch"; }

        # ── wl-clipboard ─────────────────────────────────────────────────
        # Copy the path(s) of selected entries to the Wayland clipboard.
        # <C-y> copy | <C-p> paste path
        { on = [ "<C-y>" ];    run = "plugin wl-clipboard --args=copy";  desc = "Copy path(s) to clipboard"; }
        { on = [ "<C-p>" ];    run = "plugin wl-clipboard --args=paste"; desc = "Paste path from clipboard"; }
      ];
    };
  };
}
