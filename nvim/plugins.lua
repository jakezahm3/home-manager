local enable_providers = {
	"python3_provider",
	"node_provider",
	-- and so on
}

for _, plugin in pairs(enable_providers) do
	vim.g["loaded_" .. plugin] = nil
	vim.cmd("runtime " .. plugin)
end

require("base46").load_all_highlights()
-- onfiguration using new vim.lsp.config API
return {
	{
		"neovim/nvim-lspconfig", -- REQUIRED: for native Neovim LSP integration
		lazy = false, -- REQUIRED: tell lazy.nvim to start this plugin at startup
		dependencies = {
			-- main one
			{ "ms-jpq/coq_nvim", branch = "coq" },

			-- 9000+ Snippets
			{ "ms-jpq/coq.artifacts", branch = "artifacts" },

			-- lua & third party sources -- See https://github.com/ms-jpq/coq.thirdparty
			-- Need to **configure separately**
			{ "ms-jpq/coq.thirdparty", branch = "3p" },
			-- - shell repl
			-- - nvim lua api
			-- - scientific calculator
			-- - comment banner
			-- - etc
		},
		init = function()
			vim.g.coq_settings = {
				-- Your COQ settings here
			}
		end,
		config = function()
			-- Your LSP settings here
		end,
	},
	{
		"stevearc/oil.nvim",
		---@module 'oil'
		---@type oil.SetupOpts
		opts = {},
		-- Optional dependencies
		--dependencies = { { "nvim-mini/mini.icons", opts = {} } },
		dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
		-- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
		lazy = false,
	},
	{
		"chomosuke/typst-preview.nvim",
		lazy = false, -- or ft = 'typst'
		version = "1.*",
		opts = {
			debug = true,
		}, -- lazy.nvim will implicitly calls `setup {}`
	},
	{
		{
			"rachartier/tiny-inline-diagnostic.nvim",
			event = "VeryLazy",
			priority = 1000,
			opts = {},
		},
		{
			"neovim/nvim-lspconfig",
			opts = { diagnostics = { virtual_text = false } },
		},
	},
	{
		"lervag/vimtex",
		lazy = false, -- we don't want to lazy load VimTeX
		-- tag = "v2.15", -- uncomment to pin to a specific release
		init = function()
			-- VimTeX configuration goes here, e.g.
			vim.g.vimtex_view_method = "zathura"
		end,
	},
	{
		"3rd/image.nvim",
		build = false, -- so that it doesn't build the rock https://github.com/3rd/image.nvim/issues/91#issuecomment-2453430239
		opts = {
			processor = "magick_cli",
		},
	},
	{
		"Bekaboo/dropbar.nvim",
		-- optional, but required for fuzzy finder support
		dependencies = {
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
		},
		config = function()
			local dropbar_api = require("dropbar.api")
			vim.keymap.set("n", "<Leader>;", dropbar_api.pick, { desc = "Pick symbols in winbar" })
			vim.keymap.set("n", "[;", dropbar_api.goto_context_start, { desc = "Go to start of current context" })
		end,
	},
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		---@type Flash.Config
		opts = {},
		keys = {
			{
				"s",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump()
				end,
				desc = "Flash",
			},
			{
				"S",
				mode = { "n", "x", "o" },
				function()
					require("flash").treesitter()
				end,
				desc = "Flash Treesitter",
			},
			{
				"r",
				mode = "o",
				function()
					require("flash").remote()
				end,
				desc = "Remote Flash",
			},
			{
				"R",
				mode = { "o", "x" },
				function()
					require("flash").treesitter_search()
				end,
				desc = "Treesitter Search",
			},
			{
				"<c-s>",
				mode = { "c" },
				function()
					require("flash").toggle()
				end,
				desc = "Toggle Flash Search",
			},
		},
	},
	{
		"coder/claudecode.nvim",
		dependencies = { "folke/snacks.nvim" },
		config = true,
		-- `cmd` lets lazy.nvim create command stubs that load the plugin on first use,
		-- so `:ClaudeCode` and friends work on a fresh start. Without it, a keys-only
		-- spec defers loading until a <leader>a* mapping is pressed and the commands
		-- would not exist yet.
		cmd = {
			"ClaudeCode",
			"ClaudeCodeFocus",
			"ClaudeCodeSelectModel",
			"ClaudeCodeAdd",
			"ClaudeCodeSend",
			"ClaudeCodeTreeAdd",
			"ClaudeCodeStatus",
			"ClaudeCodeStart",
			"ClaudeCodeStop",
			"ClaudeCodeOpen",
			"ClaudeCodeClose",
			"ClaudeCodeDiffAccept",
			"ClaudeCodeDiffDeny",
			"ClaudeCodeCloseAllDiffs",
		},
		keys = {
			{ "<leader>a", nil, desc = "AI/Claude Code" },
			{ "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
			{ "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
			{ "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
			{ "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
			{ "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
			{ "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
			{ "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
			{
				"<leader>as",
				"<cmd>ClaudeCodeTreeAdd<cr>",
				desc = "Add file",
				ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw", "snacks_picker_list" },
			},
			-- Diff management
			{ "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
			{ "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
		},
	},

	{ "mason-org/mason.nvim", enabled = true },
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
	{ "nvim-mini/mini.nvim", version = false, enabled = true },
	{
		"onsails/lspkind.nvim",
		enabled = true,
		config = function()
			require("lspkind").init()
		end,
	},
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			-- add any options here
		},
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
	},
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
		-- use opts = {} for passing setup options
		-- this is equivalent to setup({}) function
	},
	{
		"nvim-treesitter/nvim-treesitter",
		opts = {
			ensure_installed = {
				"html",
				"javascript",
				"latex",
				"scss",
				"svelte",
				"tsx",
				"typst",
				"vue",
				"rust",
				"css",
				"bash",
				"regex",
				"nix",
				"lua",
			},
		},
	},
	{
		"HiPhish/rainbow-delimiters.nvim",
		lazy = false,
		dependencies = "nvim-treesitter/nvim-treesitter",
		config = function()
			-- See configuration section below
			local rainbow_delimiters = require("rainbow-delimiters")

			vim.g.rainbow_delimiters = {
				strategy = {
					[""] = rainbow_delimiters.strategy["global"],
					vim = rainbow_delimiters.strategy["local"],
				},
				query = {
					[""] = "rainbow-delimiters",
					lua = "rainbow-blocks",
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
		end,
	},
	{ "nvim-lua/plenary.nvim" },
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		---@type snacks.Config
		opts = {
			image = { enabled = true },
			dashboard = { enabled = true, example = "doom" },
			scroll = { enabled = true },
			gh = { enabled = true },
			gitbrowse = { enabled = true },
			animate = { enabled = true },
			scratch = { enabled = true },
		},
	},
	{
		"ramanshrivastava/claude-complete.nvim",
		event = "InsertEnter",
		opts = {
			command = "claude", -- CLI to invoke
			model = "sonnet", -- passed as --model
			cli_args = { -- extra flags (--model is appended automatically)
				"-p",
				"--max-turns",
				"100",
				"--output-format",
				"stream-json",
				"--verbose",
				"--permission-mode",
				"bypassPermissions",
			},
			timeout_ms = 60000,
			keymaps = { -- set any to false to leave it unbound
				trigger = "<C-g>",
				accept = "<Tab>",
				cancel = "<C-c>",
			},
			context = {
				inline_full_under = 500, -- send the whole file when shorter than this
				above = 150, -- otherwise lines kept above the cursor
				below = 50, -- and below
				imports = 20, -- leading lines always included
				diagnostics = 5, -- nearest LSP diagnostics to include
				tree = 15, -- top-level project-tree entries
			},
			auto = { -- the automatic, Cursor-style lane (opt-in)
				enabled = false, -- off by default
				model = "claude-haiku-4-5", -- a cheap, fast model is strongly recommended
				debounce_ms = 350, -- idle time before a completion is requested
				idle_shutdown_min = 10, -- stop the worker after this many idle minutes
				max_filesize_kb = 500, -- skip buffers larger than this
				max_lines = 10000, -- skip buffers with more lines than this
				disabled_filetypes = { "TelescopePrompt", "snacks_picker_input", "oil" },
				show_with_menu = true, -- show ghost text even when the completion menu is open
				hint = { enabled = true, text = nil }, -- source badge; text=nil derives from the model
				blink = { enabled = false }, -- advisory flag for the blink.cmp source (see below)
				worker_env = { MAX_THINKING_TOKENS = "0" }, -- worker-only env; {} re-enables thinking
			},
			system_prompt = nil, -- string to replace the built-in prompt (manual lane)
			highlights = {
				ghost = { fg = "#b4befe", italic = true },
			},
			ui = { rich = true }, -- rich snacks panel when available, else cmdline spinner
		},
	},
	{
		"saghen/blink.cmp",
		lazy = false,
		dependencies = {
			"saghen/blink.lib",
			"rafamadriz/friendly-snippets",
		},

		-- 1. Remove the build step entirely
		build = nil,

		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = {
			keymap = { preset = "default" },
			completion = {
				documentation = { auto_show = false },
				menu = {
					draw = {
						padding = 1,
						components = {},
					},
				},
			},
			-- 2. Switch from "rust" to "lua"
			fuzzy = { implementation = "lua" },
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
			},
		},
	},

	-- {
	-- 	"saghen/blink.cmp",
	-- 	lazy = false,
	-- 	dependencies = {
	-- 		"saghen/blink.lib",
	-- 		-- optional: provides snippets for the snippet source
	-- 		"rafamadriz/friendly-snippets",
	-- 	},
	--
	-- 	-- Pass it as a function that executes the shell command explicitly
	-- 	build = function()
	-- 		vim.fn.system("nix run .#build-plugin")
	-- 	end,
	--
	-- 	---@module 'blink.cmp'
	-- 	---@type blink.cmp.Config
	-- 	opts = {
	-- 		keymap = { preset = "default" },
	-- 		completion = {
	-- 			documentation = { auto_show = false },
	-- 			menu = {
	-- 				draw = {
	-- 					padding = 1,
	-- 					components = {},
	-- 				},
	-- 			},
	-- 		},
	-- 		fuzzy = { implementation = "rust" },
	-- 		sources = {
	-- 			default = { "lsp", "path", "snippets", "buffer" },
	-- 		},
	-- 	},
	-- },
	{
		"mrcjkb/rustaceanvim",
		-- To avoid being surprised by breaking changes,
		-- I recommend you set a version range
		version = "^9",
		-- This plugin implements proper lazy-loading (see :h lua-plugin-lazy).
		-- No need for lazy.nvim to lazy-load it.
		lazy = false,
	},
}
