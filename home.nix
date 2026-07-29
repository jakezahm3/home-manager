{
  config,
  inputs,
  pkgs,
  ...
}: {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "jzahm";
  home.homeDirectory = "/home/jzahm";

  imports = [inputs.nix4nvchad.homeManagerModules.default];
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
      ast-grep
      yaml-language-server
      prettierd
      spectral-language-server
      vscode-langservers-extracted
      pyright
      rust-analyzer
      typescript-language-server
      rustc
      cargo
      git
      curl
      black
      hadolint
      shfmt
      rustfmt
      jq
      nodejs
      uv
      google-java-format
      python3
    ];
    extraConfig = ''
      vim.g.rainbow_delimiters = {
      	strategy = {
      		[""] = "rainbow-delimiters.strategy.global",
      		vim = "rainbow-delimiters.strategy.local",
      	},
      	query = {
      		[""] = "rainbow-delimiters",
      		lua = "rainbow-blocks",
      	},
      	priority = {
      		[""] = 110,
      		lua = 210,
      	},
      	highlight = {
      		"RainbowDelimiterRed",
      		"RainbowDelimiterYellow",
      		"RainbowDelimiterBlue",
      		"RainbowDelimiterOrange",
      		"RainbowDelimiterGreen",
      		"RainbowDelimiterViolet",
      		"RainbowDelimiterCyan",
      	},
      }
            -- Custom vim options
             vim.opt.shiftwidth = 2
             vim.opt.tabstop = 2
             vim.opt.expandtab = true

             -- Define custom highlight groups for supermaven
             vim.api.nvim_set_hl(0, "BlinkCmpKindSupermaven", { fg = "#7aa2f7", bold = true })
             vim.api.nvim_set_hl(0, "BlinkCmpLabelSupermaven", { fg = "#bb9af7", italic = true })

             -- LSP configuration using new vim.lsp.config API
             vim.lsp.config("nixd", {})
             vim.lsp.config("pyright", {})
             vim.lsp.config("rust_analyzer", {})
             vim.lsp.config("ts_ls", {})
             vim.lsp.config("lua_ls", {})
             vim.lsp.config("html", {})
             vim.lsp.config("cssls", {})
             vim.lsp.config("bashls", {})
             vim.lsp.config("yamlls", {})
             vim.lsp.config("jsonls", {})

             vim.lsp.enable("nixd", "pyright", "rust_analyzer", "ts_ls", "lua_ls", "html", "cssls", "bashls", "yamlls", "jsonls")

             -- Custom keymaps
             vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })

             vim.keymap.set({ "n", "v" }, "<leader>F", function()
               require("conform").format({
                 lsp_fallback = true,
                 async = false,
                 timeout_ms = 500,
               })
             end, { desc = "Format file or range (in visual mode)" })

             -- Conform formatter configuration
             require("conform").setup({
               formatters_by_ft = {
                 lua = { "stylua" },
                 css = { "prettierd" },
                 html = { "prettierd" },
                 nix = { "alejandra" },
                 json = { "jq" },
                 yaml = { "prettierd" },
                 javascript = { "prettierd" },
                 rust = { "rustfmt" },
                 python = { "black" },
                 typescript = { "prettierd" },
                 sh = { "shfmt" },
                 java = { "google-java-format" },
                 dockerfile = { "hadolint" },
                 markdown = { "prettierd" },
               },
               format_on_save = {
                 timeout_ms = 500,
                 lsp_fallback = true,
               },
             })

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
      			require("lspkind").init()
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
      					disable_inline_completion = true, -- disable inline completion to use blink.cmp instead
      					disable_keymaps = false, -- keeps built in keymaps for manual control
      					log_level = "off",
      				},
      			},
      			{
      				"huijiro/blink-cmp-supermaven",
      			},
      		},
      		build = function()
      			require("blink.cmp").build():pwait(10000)
      		end,

      		---@module 'blink.cmp'
      		---@type blink.cmp.Config
      		opts = {
      			keymap = { preset = "default" },
      			completion = {
      				documentation = { auto_show = false },
      				menu = {
      					draw = {
                  padding =  1,
      						components = {
      							kind_icon = {
      								text = function(ctx)
      									local icon = ctx.kind_icon
      									if vim.tbl_contains({ "Path" }, ctx.source_name) then
      										local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
      										if dev_icon then
      											icon = dev_icon
      										end
      									elseif ctx.source_name == "supermaven" then
      										icon = "🤖"
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
      									elseif ctx.source_name == "supermaven" then
      										hl = "BlinkCmpKindSupermaven"
      									end
      									return hl
      								end,
      							},
      							label = {
      								text = function(ctx)
      									local label = ctx.label
      									if ctx.source_name == "supermaven" then
      										return "AI: " .. label
      									end
      									return label
      								end,
      								highlight = function(ctx)
      									if ctx.source_name == "supermaven" then
      										return "BlinkCmpLabelSupermaven"
      									end
      									return ctx.label_hl
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
      						name = "supermaven",
      						module = "blink-cmp-supermaven",
      						async = true,
      						transform_items = function(ctx, items)
      							for _, item in ipairs(items) do
      								item.source_name = "supermaven"
      							end
      							return items
      						end,
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
    ".config/ghostty/config".text = builtins.readFile /home/jzahm/.config/ghostty/config.ghostty;
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
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
