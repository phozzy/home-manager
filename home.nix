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
      '';
      colorschemes.catppuccin = {
        enable = true;
        flavour = "frappe";
        integrations = {
          treesitter = true;
          telescope = true;
          neotree = true;
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
        };
        treesitter-rainbow.enable = true;
        which-key.enable = true;
        telescope = {
          enable = true;
          extensions = {
          };
          keymaps = {
            "<leader>ff" = "find_files";
            "<leader>fg" = "live_grep";
            "<leader>fb" = "buffers";
            "<leader>fh" = "help_tags";
          };
        };
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
      };
    };
  };

}
