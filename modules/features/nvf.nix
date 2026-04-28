{ self, inputs, ... }: {
  flake.nixosModules.nvf = { pkgs, ... }: {
    imports = [
      inputs.nvf.nixosModules.default
    ];

    programs.nvf = {
      enable = true;
      settings = {
        vim = {

          # ── Theme ──────────────────────────────────────────────────────────
          theme = {
            enable      = true;
            name        = "gruvbox";
            style       = "dark";
            transparent = true;
          };

          # ── Editor Options ─────────────────────────────────────────────────
          options = {
            tabstop     = 2;
            shiftwidth  = 2;
            expandtab   = true;
            number      = true;
            relativenumber = true;
            wrap        = false;
            scrolloff   = 8;
            signcolumn  = "yes";
            cursorline  = true;
            splitright  = true;
            splitbelow  = true;
          };

          # ── Clipboard ──────────────────────────────────────────────────────
          # Wayland-native — wl-copy matches your existing environment
          clipboard = {
            enable    = true;
            registers = "unnamedplus";
            providers.wl-copy.enable = true;
          };

          # ── Visuals ────────────────────────────────────────────────────────
          visuals = {
            nvim-web-devicons.enable  = true;   # icons throughout UI
            nvim-cursorline.enable    = true;   # highlight word under cursor
            fidget-nvim.enable        = true;   # LSP progress spinner (bottom-right)
            highlight-undo.enable     = true;   # flash highlight on undo/redo
            indent-blankline.enable   = true;   # indent guide lines
            # cinnamon-nvim gives smooth scroll — pairs nicely with niri animations
            cinnamon-nvim.enable      = true;
          };

          # ── Statusline ─────────────────────────────────────────────────────
          statusline.lualine = {
            enable = true;
            theme  = "gruvbox";
          };

          # ── Tabline / Buffer list ──────────────────────────────────────────
          tabline.nvimBufferline.enable = true;

          # ── File tree ──────────────────────────────────────────────────────
          filetree.nvimTree = {
            enable     = true;
            openOnSetup = false;   # don't hijack the empty buffer on startup
            setupOpts = {
              renderer.group_empty = true;
              view.width = 30;
              git.enable = true;
            };
          };

          # ── Treesitter ─────────────────────────────────────────────────────
          treesitter = {
            enable   = true;
            # context shows the current function/class scope at the top of the buffer
            context.enable = true;
            grammars = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
              nix
              lua
              python
              bash
              json
              yaml
              markdown
              markdown_inline
              toml
              kdl          # niri config files
              regex
              vim
              vimdoc
              query        # treesitter query files
            ];
          };

          # ── Telescope (fuzzy finder) ───────────────────────────────────────
          telescope.enable = true;

          # ── Auto-completion ────────────────────────────────────────────────
          # nvim-cmp with LSP, buffer and path sources
          autocomplete.nvim-cmp.enable = true;
          snippets.luasnip.enable      = true;

          # ── Autopairs ─────────────────────────────────────────────────────
          autopairs.nvim-autopairs.enable = true;

          # ── Comments ──────────────────────────────────────────────────────
          comments.comment-nvim.enable = true;

          # ── Notifications ─────────────────────────────────────────────────
          notify = {
            nvim-notify.enable = true;
          };

          # ── UI polish ─────────────────────────────────────────────────────
          ui = {
            borders.enable  = true;
            # dressing: nicer vim.ui.select / vim.ui.input popups
            fastaction.enable = true;
          };

          # ── Keybind helper ────────────────────────────────────────────────
          binds = {
            whichKey.enable = true;
            cheatsheet.enable = true;     # :Cheatsheet for searchable reference
          };

          # ── Git ────────────────────────────────────────────────────────────
          git = {
            enable      = true;
            # gitsigns shows +/-/~ in the gutter and provides hunk navigation
            gitsigns = {
              enable = true;
              setupOpts.current_line_blame = false;  # toggle with <leader>tb
            };
          };

          # ── Terminal ──────────────────────────────────────────────────────
          terminal.toggleterm = {
            enable     = true;
            lazygit.enable = true;   # <leader>gg to open lazygit
          };

          # ── LSP ────────────────────────────────────────────────────────────
          lsp = {
            enable             = true;
            formatOnSave       = true;
            lspSignature.enable = true;   # signature help while typing args
            trouble.enable      = true;   # pretty diagnostics list
            lightbulb.enable    = true;   # code-action bulb in sign column
            nvim-docs-view.enable = true; # hover docs in a side panel
          };

          # ── Languages ──────────────────────────────────────────────────────
          languages = {
            enableFormat          = true;
            enableDAP             = true;
            enableExtraDiagnostics = true;

            nix = {
              enable         = true;
              format.enable  = true;
              format.type    = [ "nixfmt" ];
            };

            # Lua — useful for editing nvf/niri scripts
            lua = {
              enable        = true;
              lsp.enable    = true;
              format.enable = true;
            };

            # Python — covers scripting (niri_tile_to_n.py, etc.)
            python = {
              enable        = true;
              lsp.enable    = true;
              format.enable = true;
              format.type   = [ "black" ];
              dap.enable    = true;
            };

            # Bash — covers your shell scripts
            bash = {
              enable        = true;
              lsp.enable    = true;
              format.enable = true;
            };

            # JSON / YAML — config file editing
            json = {
              enable        = true;
              lsp.enable    = true;
              format.enable = true;
            };

            yaml = {
              enable     = true;
              lsp.enable = true;
            };

            # Markdown — README / notes
            markdown = {
              enable                              = true;
              extensions.render-markdown-nvim.enable = true;
            };
          };

          # ── Utility ────────────────────────────────────────────────────────
          utility = {
            # View colour values (hex/rgb) in-line
            ccc.enable          = true;
            # Indent/scope motion
            motion.hop.enable = true;
            # Diff viewer (great for git history)
            diffview-nvim.enable = true;
          };

          # ── Session management ─────────────────────────────────────────────
          session.nvim-session-manager = {
            enable = true;
            setupOpts.autoload_mode = "Disabled";   # explicit :SessionLoad
          };

          # ── Dashboard / start screen ───────────────────────────────────────
          dashboard.alpha = {
            enable = true;
          };

        };
      };
    };
  };
}
