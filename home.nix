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
    pkgs.ghostty
    pkgs.corepack_24
    pkgs.python3
    pkgs.wl-clipboard
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
    neovim = pkgs.neovim.override {
      withNodeJs = true;
      withPython3 = true;
    };
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
      rustc
      cargo
      git
      curl
      black
      prettier
      hadolint
      shfmt
      rustfmt
      jq
      python3
      nodejs
      uv
      vimPlugins.nvim-treesitter.withAllGrammars
    ];
    extraConfig = ''
       -- Custom vim options
        vim.opt.shiftwidth = 2
        vim.opt.tabstop = 2
        vim.opt.expandtab = true
        vim.g.oaded_node_provider = 1
        vim.g.loaded_python3_provider = 1

        local servers = { "html", "cssls", "nixd", pyright, rust_analyzer, tsserver, lua_ls }
        vim.lsp.enable(servers)

        -- Enable specific providers
        local enable_providers = {
          "python3_provider",
          "node_provider",
          -- and so on
        }

        for _, plugin in pairs(enable_providers) do
          vim.g["loaded_" .. plugin] = nil
          vim.cmd("runtime " .. plugin)
        end

        -- Custom keymaps
        vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })

        vim.keymap.set({ "n", "v" }, "<leader>F", function()
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
            json = { "jq" },
            yaml = { "yamlfmt" },
            javascript = { "prettierd" },
            rust = { "rustfmt" },
            python = { "black" },
            typescript = { "prettierd" },
            sh = { "shfmt" },
            java = { "google-java-format" },
            dockerfile = { "hadolint" },
            markdown = { "prettierd" },
            rust = { "rustfmt" },
            
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
      return {return {
	{ "mason-org/mason.nvim", enabled = false },
	-- Disable default nvim-cmp
	{ "hrsh7th/nvim-cmp", enabled = false },
	-- Also disable cmp dependencies that might conflict
	{ "L3MON4D3/LuaSnip", enabled = false },
	{ "saadparwaiz1/cmp_luasnip", enabled = false },
	{ "hrsh7th/cmp-nvim-lua", enabled = false },
	{ "hrsh7th/cmp-nvim-lsp", enabled = false },
	{ "hrsh7th/cmp-buffer", enabled = false },
	{ "hrsh7th/cmp-path", enabled = false },
	{ "windwp/nvim-autopairs", enabled = true },
	{
		"onsails/lspkind.nvim",
		enabled = true,
		config = function()
			require("lspkind").init({
				symbol_map = {
					Supermaven = "",
				},
			})
		end,
	},

	{ "nvim-lua/plenary.nvim" },
	{
		"saghen/blink.cmp",
		lazy = false,
		dependencies = {
			"saghen/blink.lib",
			-- optional: provides snippets for the snippet source
			"rafamadriz/friendly-snippets",
			{
				"supermaven-inc/supermaven-nvim",
				opts = {
					disable_inline_completion = false, -- enable inline completion to suppress warnings
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
			completion = {
				documentation = { auto_show = false },
				menu = {
					draw = {
            padding = { 0, 1 },
						components = {
							kind_icon = {
								text = function(ctx)
									local icon = ctx.kind_icon
									if vim.tbl_contains({ "Path" }, ctx.source_name) then
										local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
										if dev_icon then
											icon = dev_icon
										end
									else
										icon = require("lspkind").symbol_map[ctx.kind] or ""
									end

									return icon .. ctx.icon_gap
								end,

								-- Optionally, use the highlight groups from nvim-web-devicons
								-- You can also add the same function for `kind.highlight` if you want to
								-- keep the highlight groups in sync with the icons.
								highlight = function(ctx)
									local hl = ctx.kind_hl
									if vim.tbl_contains({ "Path" }, ctx.source_name) then
										local dev_icon, dev_hl = require("nvim-web-devicons").get_icon(ctx.label)
										if dev_icon then
											hl = dev_hl
										end
									end
									return hl
								end,
							},
						},
					},
				},
			},
			fuzzy = { implementation = "rust" },
			sources = {
				default = { "lsp", "path", "snippets", "buffer", "supermaven" },
				providers = {
					supermaven = {
						transform_items = function(ctx, items)
							for _, item in ipairs(items) do
								item.kind_icon = ""
								item.kind_name = "supermaven"
							end
							return items
						end,
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

    # Ghostty terminal configuration
    ".config/ghostty/config".source = /home/jzahm/.config/ghostty/config.ghostty;
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
