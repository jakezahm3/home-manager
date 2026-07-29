{
  config,
  inputs,
  pkgs,
  ...
}:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "jzahm";
  home.homeDirectory = "/home/jzahm";

  imports = [ inputs.nix4nvchad.homeManagerModules.default ];

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "26.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    pkgs.yazi
    pkgs.fish
    pkgs.tealdeer
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

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

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -gx EDITOR "nvim"
      set -gx VISUAL "nvim"
    '';
  };

  programs.nvchad = {
    backup = false;
    enable = true;
    neovim = pkgs.neovim-unwrapped;
    extraPackages = with pkgs; [
      ripgrep
      lua-language-server
      stylua
      bash-language-server
      nixd
      alejandra
      nixfmt
      ast-grep
      yaml-language-server
      prettierd
      spectral-language-server
      ast-grep
      vimPlugins.supermaven-nvim
      # Dependencies for blink.cmp
      rustc
      cargo
      git
      curl
    ];
    extraConfig = ''
       -- Custom vim options
        vim.opt.shiftwidth = 2
        vim.opt.tabstop = 2
        vim.opt.expandtab = true

        local servers = { "html", "cssls", "nixd" }
        vim.lsp.enable(servers)

        -- Custom keymaps
        vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })

        vim.keymap.set({ "n", "v" }, "<leader>mp", function()
          require("conform").format({
            lsp_fallback = true,
            async = false,
            timeout_ms = 500,
          })
        end, { desc = "Format file or range (in visual mode)" })

        
        local options = {

          formatters_by_ft = {
            lua = { "stylua" },
            css = { "prettierd" },
            html = { "prettierd" },
            nix = { "alejandra" },
            json = { "spectral-language-server" },
            yaml = { "yamlfmt" },
          },

           format_on_save = {
             -- These options will be passed to conform.format()
           timeout_ms = 500,
           lsp_fallback = true,
          },
        }

      return options

    '';
    chadrcConfig = ''
      ---@type ChadrcConfig
      local M = {}

      M.base46 = {
      	theme = "eldritch",

      	 hl_override = {
      	 	Comment = { italic = true },
      	 	["@comment"] = { italic = true },
      	 },
      }

       M.nvdash = { load_on_startup = true }
       M.ui = {
             tabufline = {
                lazyload = false
            },
       }

      return M
    '';
    extraPlugins = ''
      return {
        -- Disable default nvim-cmp
      	{ "hrsh7th/nvim-cmp", enabled = false },
      	-- Also disable cmp dependencies that might conflict
      	{ "L3MON4D3/LuaSnip", enabled = false },
      	{ "saadparwaiz1/cmp_luasnip", enabled = false },
      	{ "hrsh7th/cmp-nvim-lua", enabled = false },
      	{ "hrsh7th/cmp-nvim-lsp", enabled = false },
      	{ "hrsh7th/cmp-buffer", enabled = false },
      	{ "hrsh7th/cmp-path", enabled = false },
      	{ "windwp/nvim-autopairs", enabled = false },
      	
      	{ "nvim-lua/plenary.nvim" },
      	{
      			"supermaven-inc/supermaven-nvim",
      			config = function()
      				require("supermaven-nvim").setup({})
      			end,
      	},
      	{
      		"saghen/blink.cmp",
      		dependencies = {
      			"saghen/blink.lib",
      			-- optional: provides snippets for the snippet source
      			"rafamadriz/friendly-snippets",
      			{
      				"supermaven-inc/supermaven-nvim",
      				opts = {
      					disable_inline_completion = true, -- disables inline completion for use with cmp
      					disable_keymaps = false, -- disables built in keymaps for more manual control
      				},
      			},
      			{
      				"huijiro/blink-cmp-supermaven",
      			},
      		},
      		build = function()
      			require("blink.cmp").build():pwait(1000000)
      		end,

      		---@module 'blink.cmp'
      		---@type blink.cmp.Config
      		opts = {
      			keymap = { preset = "default" },
      			completion = { documentation = { auto_show = false } },
      			fuzzy = { implementation = "rust" },
      			sources = {
      				default = { "lsp", "path", "snippets", "buffer", "supermaven" },
      				providers = {
      					supermaven = {
      						name = "supermaven",
      						module = "blink-cmp-supermaven",
      						async = true,
      					},
      				},
      			},
      		},
      	},
      }
    '';
  };

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

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/jzahm/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "vim";
    VISUAL = "vim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
