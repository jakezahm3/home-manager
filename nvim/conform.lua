local options = {
	formatters_by_ft = {
		lua = { "stylua" },
		css = { "prettierd" },
		html = { "prettierd" },
		json = { "prettierd" },
		yaml = { "prettierd" },
		python = { "black" },
		nix = { "alejandra" },
		markdown = { "prettierd" },
		typescript = { "prettierd" },
		javascript = { "prettierd" },
		rust = { "rustywind" },
		bash = { "beautysh" },
		toml = { "taplo" },
	},
	format_on_save = {
		-- These options will be passed to conform.format()
		timeout_ms = 500,
		lsp_fallback = true,
	},
}

return options
