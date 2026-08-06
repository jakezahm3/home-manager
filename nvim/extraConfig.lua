-- Provider configurat/lua_lsion
vim.g.python3_host_prog = "@PYTHON3_HOST_PROG@"
vim.g.node_host_prog = vim.fn.exepath("neovim-node-host")
vim.g.loaded_python3_provider = nil
vim.g.loaded_node_provider = nil
-- Disable Claude's extended thinking for any `claude` CLI subprocess Neovim
-- spawns (claude-complete.nvim's manual <C-g> lane in particular): thinking-only
-- turns emit no text content block, which claude-complete.nvim silently drops
-- (no ghost text, no error) instead of falling back to the tool_use/thinking output.
vim.env.MAX_THINKING_TOKENS = "0"
-- Custom vim options
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.expandtab = true
-- Define custom highlight groups for supermaven
vim.api.nvim_set_hl(0, "BlinkCmpKindSupermaven", { fg = "#7aa2f7", bold = true })
vim.api.nvim_set_hl(0, "BlinkCmpLabelSupermaven", { fg = "#bb9af7", italic = true })

local dropbar = require("dropbar")
local sources = require("dropbar.sources")
local utils = require("dropbar.utils")

vim.api.nvim_set_hl(0, "DropBarFileName", { fg = "#FFFFFF", italic = true })

local custom_path = {
	get_symbols = function(buff, win, cursor)
		local symbols = sources.path.get_symbols(buff, win, cursor)
		symbols[#symbols].name_hl = "DropBarFileName"
		if vim.bo[buff].modified then
			symbols[#symbols].name = symbols[#symbols].name .. " [+]"
			symbols[#symbols].name_hl = "DiffAdded"
		end
		return symbols
	end,
}

require("dropbar").setup({
	bar = {
		enable = function(buf, win, _)
			buf = vim._resolve_bufnr(buf)
			if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_win_is_valid(win) then
				return false
			end

			if
				not vim.api.nvim_buf_is_valid(buf)
				or not vim.api.nvim_win_is_valid(win)
				or vim.fn.win_gettype(win) ~= ""
				or vim.wo[win].winbar ~= ""
				or vim.bo[buf].ft == "help"
			then
				return false
			end

			local stat = vim.uv.fs_stat(vim.api.nvim_buf_get_name(buf))
			if stat and stat.size > 1024 * 1024 then
				return false
			end

			return vim.bo[buf].bt == "terminal"
				or vim.bo[buf].ft == "markdown"
				or pcall(vim.treesitter.get_parser, buf)
				or not vim.tbl_isempty(vim.lsp.get_clients({
					bufnr = buf,
					method = "textDocument/documentSymbol",
				}))
		end,
	},
	sources = {
		path = {
			relative_to = function(buf, win)
				-- Show full path in oil or fugitive buffers
				local bufname = vim.api.nvim_buf_get_name(buf)
				if vim.startswith(bufname, "oil://") or vim.startswith(bufname, "fugitive://") then
					local root = bufname:gsub("^%S+://", "", 1)
					while root and root ~= vim.fs.dirname(root) do
						root = vim.fs.dirname(root)
					end
					return root
				end

				local ok, cwd = pcall(vim.fn.getcwd, win)
				return ok and cwd or vim.fn.getcwd()
			end,
		},
	},
})

local servers = {
	nixd = {},
	pyright = {},
	rust_analyzer = {},
	ts_ls = {},
	html = {},
	cssls = {},
	bashls = {},
	yamlls = {},
	jsonls = {},
	fish_lsp = {},
	lua_ls = {},
}

for name, opts in pairs(servers) do
	vim.lsp.config(name, opts)
	vim.lsp.enable(name)
end

local autocmd = vim.api.nvim_create_autocmd

autocmd("VimEnter", {
	command = ":silent !kitty @ set-spacing padding=0 margin=0",
})

autocmd("VimLeavePre", {
	command = ":silent !kitty @ set-spacing padding=20 margin=10",
})

autocmd("BufReadPost", {
	pattern = "*",
	callback = function()
		local line = vim.fn.line("'\"")
		if
			line > 1
			and line <= vim.fn.line("$")
			and vim.bo.filetype ~= "commit"
			and vim.fn.index({ "xxd", "gitrebase" }, vim.bo.filetype) == -1
		then
			vim.cmd('normal! g`"')
		end
	end,
})

vim.api.nvim_create_autocmd("BufDelete", {
	callback = function()
		local bufs = vim.t.bufs
		if #bufs == 1 and vim.api.nvim_buf_get_name(bufs[1]) == "" then
			vim.cmd("Nvdash")
		end
	end,
})

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
		markdown = { "prettierd" },
		fish = { "fish_indent" },
	},
	format_on_save = {
		timeout_ms = 500,
		lsp_fallback = true,
	},
})
