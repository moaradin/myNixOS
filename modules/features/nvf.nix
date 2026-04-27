{ self, inputs, ... }: {

  flake.nixosModules.nvf = { pkgs, ... }: {

    imports = [
      inputs.nvf.nixosModules.default  # Provides programs.nvf.*
    ];

    programs.nvf = {
      enable = true;

      settings.vim = {

        # ── Aliases ───────────────────────────────────────────────────────────

        viAlias  = true;
        vimAlias = true;

        # ── Core Editor Behaviour ─────────────────────────────────────────────

        lineNumberMode       = "relNumber";  # relative + current absolute
        syntaxHighlighting   = true;
        preventJunkFiles     = true;         # no swap/backup/undo files scattered around
        searchCase           = "smart";      # case-insensitive unless you type a capital
        hideSearchHighlight  = true;         # clear highlights after moving off search
        useSystemClipboard   = true;         # sync + and * registers with wl-clipboard
        enableLuaLoader      = true;         # byte-compile Lua modules for faster startup
        bell                 = "visual";     # no audio bell

        # ── Globals ───────────────────────────────────────────────────────────

        globals = {
          mapleader      = " ";
          maplocalleader = ",";
        };

        # ── Options (passed straight to vim.opt) ──────────────────────────────

        options = {
          shiftwidth  = 2;
          tabstop     = 2;
          expandtab   = true;
          scrolloff   = 8;          # keep 8 lines above/below cursor
          sidescrolloff = 8;
          wrap        = false;
          colorcolumn = "100";
          signcolumn  = "yes";      # always show, avoids layout jumps
          splitright  = true;
          splitbelow  = true;
          cursorline  = true;
          termguicolors = true;
        };

        # ── Theme ─────────────────────────────────────────────────────────────

        theme = {
          enable = true;
          name   = "catppuccin";
          style  = "mocha";
          transparent = false;
        };

        # ── Treesitter ────────────────────────────────────────────────────────

        treesitter = {
          enable = true;
          autotagHtml = true;
          # grammars for languages nvf doesn't auto-install via language modules
          grammars = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
            kdl       # your niri config files
            fish
            sql
            dockerfile
            toml
            yaml
            json
            markdown
            markdown_inline
            regex
            comment
          ];
        };

        # ── LSP ───────────────────────────────────────────────────────────────

        lsp = {
          enable              = true;
          formatOnSave        = true;
          lspkind.enable      = true;   # pictogram icons in completion menu
          lspsaga.enable      = true;   # richer LSP UI (code actions, hover)
          nvimCodeActionMenu.enable = false;
          trouble.enable      = true;   # diagnostics panel
          lspSignature.enable = true;   # parameter hints while typing

          mappings = {
            goToDeclaration      = "<leader>lD";
            goToDefinition       = "<leader>ld";
            goToType             = "<leader>lt";
            listImplementations  = "<leader>li";
            listReferences       = "<leader>lr";
            hover                = "K";
            signatureHelp        = "<C-k>";
            nextDiagnostic       = "]d";
            previousDiagnostic   = "[d";
            openDiagnosticFloat  = "<leader>le";
            renameSymbol         = "<leader>lR";
            codeAction           = "<leader>la";
            format               = "<leader>lf";
            documentHighlight    = "<leader>lh";
          };
        };

        # ── Languages ─────────────────────────────────────────────────────────
        # Each language block enables Treesitter + LSP + formatter automatically.

        languages = {

          enableLSP        = true;   # global toggle for all per-language LSPs
          enableFormat     = true;   # global toggle for all per-language formatters
          enableTreesitter = true;   # global toggle for all per-language grammars
          enableExtraDiagnostics = true;

          # Nix — nixd for evaluation-aware completions, alejandra for formatting
          nix = {
            enable    = true;
            lsp.enable   = true;
            lsp.servers  = [ "nixd" ];   # list — "nil" is the other option
            format.enable = true;
            extraDiagnostics.enable = true;
          };

          # Lua — for editing this very nvf config and other Neovim plugins
          lua = {
            enable    = true;
            lsp.enable   = true;
            format.enable = true;
            extraDiagnostics.enable = true;
          };

          # Python
          python = {
            enable    = true;
            lsp.enable   = true;
            format.enable = true;
            extraDiagnostics.enable = true;
          };

          # Bash / shell scripts
          bash = {
            enable    = true;
            lsp.enable   = true;
            format.enable = true;
            extraDiagnostics.enable = true;
          };

          # Go — you have `go` in systemPackages
          go = {
            enable    = true;
            lsp.enable   = true;
            format.enable = true;
            extraDiagnostics.enable = true;
          };

          # Markdown — notes, READMEs
          markdown = {
            enable    = true;
            lsp.enable   = true;
            format.enable = true;
            extraDiagnostics.enable = true;
          };

          # YAML — NixOS hardware/config files, GitHub Actions etc.
          yaml = {
            enable    = true;
            lsp.enable   = true;
            format.enable = true;
            extraDiagnostics.enable = true;
          };

          # TOML — Cargo.toml, pyproject.toml etc.
          toml = {
            enable    = true;
            lsp.enable   = true;
            format.enable = true;
          };

          # HTML / CSS
          html = {
            enable    = true;
            lsp.enable   = true;
            format.enable = true;
          };

          css = {
            enable    = true;
            lsp.enable = true;
          };

        };

        # ── Completion ────────────────────────────────────────────────────────

        autocomplete = {
          nvim-cmp.enable = true;
          # Sources are added automatically by language modules;
          # add extras here if needed:
          # nvim-cmp.sources.buffer = "[Buffer]";
          # nvim-cmp.sources.path   = "[Path]";
        };

        # ── Snippets ──────────────────────────────────────────────────────────

        snippets.luasnip.enable = true;

        # ── Telescope ─────────────────────────────────────────────────────────

        telescope.enable = true;

        # ── File Explorer ─────────────────────────────────────────────────────

        filetree.neo-tree = {
          enable = true;
          mappings.toggle = "<leader>e";
        };

        # ── Status Line ───────────────────────────────────────────────────────

        statusline.lualine = {
          enable = true;
          theme  = "catppuccin";
        };

        # ── Bufferline ────────────────────────────────────────────────────────

        tabline.nvimBufferline.enable = true;

        # ── Dashboard ─────────────────────────────────────────────────────────

        dashboard.alpha.enable = true;

        # ── Git ───────────────────────────────────────────────────────────────

        git = {
          enable        = true;
          gitsigns.enable = true;
          gitsigns.codeActions.enable = true;   # stage hunk via code-action menu

          # lazygit — you already have it in systemPackages
          lazygit.enable = true;
          mappings.lazygit = "<leader>gg";
        };

        # ── Terminal ──────────────────────────────────────────────────────────

        terminal.toggleterm = {
          enable    = true;
          direction = "float";   # float | horizontal | vertical | tab
          mappings.open = "<leader>t";
        };

        # ── Notes ─────────────────────────────────────────────────────────────

        notes.todo-comments.enable = true;   # highlight TODO / FIXME / HACK etc.

        # ── UI Extras ─────────────────────────────────────────────────────────

        ui = {
          borders = {
            enable      = true;
            globalStyle = "rounded";
          };
          fastaction.enable   = true;   # prettier code-action picker
          illuminate.enable   = true;   # highlight other uses of word under cursor
          modes-nvim.enable   = false;  # colour-coded cursor (optional, set true to try)
          noice.enable        = true;   # replaces cmdline + notifications with floating UI
          smartcolumn = {
            enable            = true;
            columnAt.languages = {
              nix    = 100;
              python = 88;
              go     = 120;
            };
          };
        };

        # ── Indent Guides ─────────────────────────────────────────────────────

        visuals = {
          nvim-scrollbar.enable    = true;
          nvim-web-devicons.enable = true;
          nvim-cursorline.enable   = true;
          cinnamon-nvim.enable     = true;   # smooth scrolling
          fidget-nvim.enable       = true;   # LSP progress spinner (bottom-right)
          highlight-undo.enable    = true;   # flash highlight on undo/redo
          indent-blankline.enable  = true;
        };

        # ── Which-Key ─────────────────────────────────────────────────────────

        binds = {
          whichKey.enable = true;
          cheatsheet.enable = true;
        };

        # ── Pairs & Surround ──────────────────────────────────────────────────

        autopairs.nvim-autopairs.enable = true;

        utility = {
          surround.enable        = true;   # ys / cs / ds surround motions
          diffview-nvim.enable   = true;   # rich git diff viewer
          icon-picker.enable     = true;   # pick Nerd Font icons inline
          vim-wakatime.enable    = false;  # set true if you use WakaTime
          motion = {
            hop.enable    = false;
            leap.enable   = true;          # s / S leap motion
            precognition.enable = false;
          };
          images = {
            image-nvim.enable = false;     # set true for kitty/ueberzug image preview
          };
        };

        # ── Session ───────────────────────────────────────────────────────────

        session.nvim-session-manager.enable = true;

        # ── Spell ─────────────────────────────────────────────────────────────

        spellcheck = {
          enable    = true;
          languages = [ "en" ];
        };

      };
    };

  };

}
