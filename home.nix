{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "deck";
  home.homeDirectory = "/home/deck";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello
    pkgs.awscli2
    pkgs.fd
    pkgs.ripgrep

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # You can also manage environment variables but you will have to manually
  # source
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/deck/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs = {
    home-manager.enable = true;
    nixvim = {
      enable = true;
      globals = {
        # Set leader key
        mapleader = "\ ";
        maplocalleader = "\ ";
        # Fix markdown indentation settings
        markdown_recommended_style = 0;
      };
      options = {
        # Enable auto write
        autowrite = true;
        # Hide * markup for bold and italic
        conceallevel = 3;
        # Confirm to save changes before exiting modified buffer
        confirm = true;
        # Show line numbers
        number = true;
        # Enable highlighting of the current line
        cursorline = true;
        # Show some invisible characters (tabs...
        list = true;
        # Use spaces instead of tabs
        expandtab = true;
        # Round indent
        shiftround = true;
        # Size of an indent
        shiftwidth = 2;
        # Stop sign for lines greater than 80 symbols
        colorcolumn = "80";
        # Sync with system clipboard
        clipboard = "unnamedplus";
        # ...
        completeopt = "menu,menuone,noselect";
        # tcqj
        formatoptions = "jcroqlnt";
        # ...
        grepformat = "%f:%l:%c:%m";
        # ...
        grepprg = "rg --vimgrep";
        # Ignore case
        ignorecase = true;
        # Preview incremental substitute
        inccommand = "nosplit";
        # ...
        laststatus = 0;
        # Enable mouse mode
        mouse = "a";
        # Popup blend
        pumblend = 10;
        # Maximum number of entries in a popup
        pumheight = 10;
        # Lines of context
        scrolloff = 4;
        # Columns of context
        sidescrolloff = 8;
        # TDDO! Change to false after status line installed
        showmode = true;
        # Always show the signcolumn, otherwise it would shift the text each time
        signcolumn = "yes";
        # Don't ignore case with capitals
        smartcase = true;
        # Insert indents automatically
        smartindent = true;
        # Put new windows below current
        splitbelow = true;
        # Put new windows right of current
        splitright = true;
        # Number of spaces tabs count for
        tabstop = 2;
        # True color support
        termguicolors = true;
        # ...
        timeoutlen = 300;
        # Use undofile
        undofile = true;
        # Undo's to remember
        undolevels = 10000;
        # Save swap file and trigger CursorHold
        updatetime = 200;
        # Command-line completion mode
        wildmode = "longest:full,full";
        # Minimum window width
        winminwidth = 5;
        # ...
        sessionoptions = [
          "buffers"
          "curdir"
          "tabpages"
          "winsize"
        ];
        # ...
        spelllang = [ "en" ];
      };
      extraConfigLuaPre = ''
        vim.opt.shortmess:append({ W = true, I = true, c = true })
        local has_words_before = function()
          unpack = unpack or table.unpack
          local line, col = unpack(vim.api.nvim_win_get_cursor(0))
          return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
        end
        local get_root = function()
          local root_patterns = { ".git", "lua" }
          ---@type string?
          local path = vim.api.nvim_buf_get_name(0)
          path = path ~= "" and vim.loop.fs_realpath(path) or nil
          ---@type string[]
          local roots = {}
          if path then
            for _, client in pairs(vim.lsp.get_active_clients({ bufnr = 0 })) do
              local workspace = client.config.workspace_folders
              local paths = workspace and vim.tbl_map(function(ws)
                return vim.uri_to_fname(ws.uri)
              end, workspace) or client.config.root_dir and { client.config.root_dir } or {}
              for _, p in ipairs(paths) do
                local r = vim.loop.fs_realpath(p)
                if path:find(r, 1, true) then
                  roots[#roots + 1] = r
                end
              end
            end
          end
          table.sort(roots, function(a, b)
            return #a > #b
          end)
          ---@type string?
          local root = roots[1]
          if not root then
            path = path and vim.fs.dirname(path) or vim.loop.cwd()
            ---@type string?
            root = vim.fs.find(root_patterns, { path = path, upward = true })[1]
            root = root and vim.fs.dirname(root) or vim.loop.cwd()
          end
          ---@cast root string
          return root
        end
      '';
      maps = {
        normal."g" = {
          desc = "+goto";
        };
        normal."gz" = {
          desc = "+surround";
        };
        normal."]" = {
          desc = "+next";
        };
        normal."[" = {
          desc = "+prev";
        };
        normal."<leader><tab>" = {
          desc = "+tabs";
        };
        normal."<leader>," = {
          lua = true;
          action = ''
            function()
              require('telescope.builtin').buffers({
                show_all_buffers = true,
              })
            end
          '';
          desc = "Switch Buffer";
        };
        normal."<leader>/" = {
          lua = true;
          action = ''
            function()
              require('telescope.builtin').live_grep()
            end
          '';
          desc = "Grep (root dir)";
        };
        normal."<leader>:" = {
          lua = true;
          action = ''
            function()
              require('telescope.builtin').command_history()
            end
          '';
          desc = "Command History";
        };
        # Telescope file_browser
        normal."<leader><space>" = {
          lua = true;
          action = ''
            function()
              require('telescope').extensions.file_browser.file_browser({
                cwd = get_root(),
              })
            end
          '';
          desc = "Telescope file_browser (root_dir)";
        };
        normal."<leader><S-space>" = {
          lua = true;
          action = ''
            function()
              require('telescope').extensions.file_browser.file_browser({
              })
            end
          '';
          desc = "Telescope file_browser (cwd)";
        };
        normal."<leader>b" = {
          desc = "+buffer";
        };
        normal."<leader>c" = {
          desc = "+code";
        };
        normal."<leader>f" = {
          desc = "+file/find";
        };
        normal."<leader>fb" = {
          lua = true;
          action = ''
            function()
              require('telescope.builtin').buffers()
            end
          '';
          desc = "Buffers";
        };
        normal."<leader>fe" = {
          lua = true;
          action = ''
            function()
              require("neo-tree.command").execute({ toggle = true, dir = get_root() })
            end
          '';
          desc = "Explorer NeoTree (root dir)";
        };
        normal."<leader>fE" = {
          lua = true;
          action = ''
            function()
              require("neo-tree.command").execute({ toggle = true, dir = vim.loop.cwd() })
            end
          '';
          desc = "Explorer NeoTree (cwd)";
        };
        normal."<leader>ff" = {
          lua = true;
          action = ''
            function()
              require('telescope.builtin').find_files({
                cwd = get_root(),
              })
            end
          '';
          desc = "Find Files (root dir)";
        };
        normal."<leader>fF" = {
          lua = true;
          action = ''
            function()
              require('telescope.builtin').find_files()
            end
          '';
          desc = "Find Files (cwd)";
        };
        normal."<leader>fr" = {
          lua = true;
          action = ''
            function()
              require('telescope.builtin').oldfiles()
            end
          '';
          desc = "Recent";
        };
        normal."<leader>fR" = {
          lua = true;
          action = ''
            function()
              require('telescope.builtin').oldfiles({
                    cwd = vim.loop.cwd(),
                  })
            end
          '';
          desc = "Recent (cwd)";
        };
        normal."<leader>g" = {
          desc = "+git/GoTo";
        };
        normal."<leader>gc" = {
          lua = true;
          action = ''
            function()
              require("telescope.builtin").git_commits()
            end
          '';
          desc = "commits";
        };
        normal."<leader>gg" = {
          lua = true;
          action = ''
            function()
              require('neogit').open({
                kind = 'tab',
                cwd = get_root(),
              })
            end
          '';
          desc = "Neogit (root dir)";
        };
        normal."<leader>gG" = {
          lua = true;
          action = ''
            function()
              require('neogit').open({
                kind = 'tab',
              })
            end
          '';
          desc = "Neogit (cwd)";
        };
        normal."<leader>gh" = {
          desc = "+hunks";
        };
        normal."<leader>gs" = {
          lua = true;
          action = ''
            function()
              require("telescope.builtin").git_status()
            end
          '';
          desc = "status";
        };
        normal."<leader>q" = {
          desc = "+quit/session";
        };
        normal."<leader>s" = {
          desc = "+search";
        };
        normal."<leader>s\"" = {
          lua = true;
          action = ''
            function()
              require("telescope.builtin").registers()
            end
          '';
          desc = "Regitsters";
        };
        normal."<leader>sa" = {
          lua = true;
          action = ''
            function()
              require("telescope.builtin").autocommands()
            end
          '';
          desc = "Auto Commands";
        };
        normal."<leader>u" = {
          desc = "+ui";
        };
        normal."<leader>w" = {
          desc = "+windows";
        };
        normal."<leader>x" = {
          desc = "+diagnostics/quickfix";
        };
      };
      colorschemes.catppuccin = {
        enable = true;
        flavour = "frappe";
        integrations = {
          treesitter = true;
          treesitter_context = true;
          telescope = true;
          gitsigns = true;
          lsp_trouble = true;
          neotree = true;
          notify = true;
          ts_rainbow = true;
          which_key =true;
        };
      };
      plugins = {
        treesitter = {
          enable = true;
          folding = true;
          incrementalSelection.enable = true;
          indent = true;
          nixvimInjections = true;
        };
        treesitter-context.enable = true;
        treesitter-rainbow.enable = true;
        treesitter-refactor = {
          enable = true;
          highlightCurrentScope.enable = true;
          highlightDefinitions.enable = true;
          navigation = {
            enable = true;
          };
          smartRename = {
            enable = true;
          };
        };
        trouble.enable = true;
        which-key.enable = true;
        telescope = {
          enable = true;
          extensions = {
            file_browser.enable = true;
          };
        };
        gitsigns = {
          enable = true;
          currentLineBlame = true;
          trouble = true;
          onAttach.function = ''
            function(buffer)
              local gs = package.loaded.gitsigns
              local function map(mode, l, r, desc)
                vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
              end
              map("n", "]h", gs.next_hunk, "Next Hunk")
              map("n", "[h", gs.prev_hunk, "Prev Hunk")
              map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
              map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
              map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
              map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
              map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
              map("n", "<leader>ghp", gs.preview_hunk, "Preview Hunk")
              map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
              map("n", "<leader>ghd", gs.diffthis, "Diff This")
              map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
              map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
            end
          '';
        };
        neogit.enable = true;
        notify.enable = true;
        neo-tree.enable = true;
        lsp = {
          enable = true;
          servers = {
            bashls.enable = true;
            gopls.enable = true;
            lua-ls.enable = true;
            nil_ls.enable = true;
            nixd.enable = true;
            pylsp.enable = true;
            pyright.enable = true;
            rnix-lsp.enable = true;
            ruff-lsp.enable = true;
            rust-analyzer.enable = true;
            terraformls.enable = true;
            yamlls.enable = true;
          };
        };
        lspkind.enable = true;
        indent-blankline = {
          enable = true;
          useTreesitter = true;
          useTreesitterScope = true;
        };
        nvim-autopairs.enable = true;
        luasnip = {
          enable = true;
          fromVscode = [ { } ];
        };
        cmp-buffer.enable = true;
        cmp-cmdline.enable = true;
        cmp-cmdline-history.enable = true;
        cmp-dap.enable = true;
        cmp_luasnip.enable = true;
        cmp-nvim-lsp.enable = true;
        cmp-nvim-lsp-document-symbol.enable = true;
        cmp-nvim-lsp-signature-help.enable = true;
        cmp-nvim-lua.enable = true;
        cmp-omni.enable = true;
        cmp-path.enable = true;
        cmp-treesitter.enable = true;
        nvim-cmp = {
          enable = true;
          snippet.expand = "luasnip";
          mapping = {
            "<C-n>" = ''
              cmp.mapping.select_next_item({
                behavior = cmp.SelectBehavior.Insert
              })
            '';
            "<C-p>" = ''
              cmp.mapping.select_prev_item({
                behavior = cmp.SelectBehavior.Insert
              })
            '';
            "<C-b>" = ''
              cmp.mapping.scroll_docs(-4)
            '';
            "<C-f>" = ''
              cmp.mapping.scroll_docs(4)
            '';
            "<C-Space>" = ''
              cmp.mapping.complete()
            '';
            "<C-e>" = ''
              cmp.mapping.abort()
            '';
            "<CR>" = ''
              cmp.mapping.confirm({
                select = true
              })
            '';
            "<S-CR>" = ''
              cmp.mapping.confirm({
                behavior = cmp.ConfirmBehavior.Replace,
                select = true,
              })
            '';
            "<Tab>" = {
              modes = ["i" "s"];
              action = ''
                function(fallback)
                  if cmp.visible() then
                    cmp.select_next_item()
                  elseif require("luasnip").expand_or_locally_jumpable() then
                    require("luasnip").expand_or_jump()
                  elseif has_words_before() then
                    cmp.complete()
                  else
                    fallback()
                  end
                end
              '';
            };
            "<S-Tab>" = {
              modes = ["i" "s"];
              action = ''
                function(fallback)
                  if cmp.visible() then
                    cmp.select_prev_item()
                  elseif require("luasnip").jumpable(-1) then
                    require("luasnip").jump(-1)
                  else
                    fallback()
                  end
                end
              '';
            };
          };
          mappingPresets = [
            "insert"
          ];
          sources = [
            { name = "nvim_lsp"; }
            { name = "luasnip"; }
            { name = "path"; }
            { name = "buffer"; }
          ];
        };
      };
    };
  };

}
