local enable_providers = {
	"python3_provider",
	"node_provider",
	-- and so on
}

for _, plugin in pairs(enable_providers) do
	vim.g["loaded_" .. plugin] = nil
	vim.cmd("runtime " .. plugin)
end

return {
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
		"HiPhish/rainbow-delimiters.nvim",
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
						padding = 1,
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
