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

-- Define a custom color named 'MyYankColor' with a dark purple background
vim.api.nvim_set_hl(0, "MyYankColor", { bg = "#d700ff", fg = "#000000" })

vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank({
			higroup = "MyYankColor", -- Use your custom group here
			timeout = 200,
		})
	end,
})

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
	texlab = {},
	tinymist = {},
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

vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

vim.keymap.set({ "n", "v" }, "<leader>F", function()
	require("conform").format({
		lsp_fallback = true,
		async = false,
		timeout_ms = 500,
	})
end, { desc = "Format file or range (in visual mode)" })

-- Format via the LSP server directly, bypassing conform.nvim
vim.api.nvim_create_user_command("LspFormat", function(args)
	local range = nil
	if args.range > 0 then
		range = {
			["start"] = { args.line1, 0 },
			["end"] = { args.line2, 0 },
		}
	end
	vim.lsp.buf.format({ async = false, timeout_ms = 500, range = range })
end, { range = true, desc = "Format file or range with the LSP formatter" })

vim.keymap.set({ "n", "v" }, "<leader>lQ", "<cmd>LspFormat<CR>", { desc = "Format file or range with LSP" })

local bufnr = vim.api.nvim_get_current_buf()
vim.keymap.set("n", "<leader>A", function()
	vim.cmd.RustLsp("codeAction") -- supports rust-analyzer's grouping
	-- or vim.lsp.buf.codeAction() if you don't want grouping.
end, { silent = true, buffer = bufnr })
vim.keymap.set(
	"n",
	"K", -- Override Neovim's built-in hover keymap with rustaceanvim's hover actions
	function()
		vim.cmd.RustLsp({ "hover", "actions" })
	end,
	{ silent = true, buffer = bufnr }
)
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
		rust = { "ast-grep" },
		python = { "black" },
		typescript = { "prettierd" },
		sh = { "shfmt" },
		java = { "google-java-format" },
		markdown = { "prettierd" },
		fish = { "fish_indent" },
		latex = { "tex-fmt" },
		typst = { "prettypst" },
	},
	format_on_save = {
		timeout_ms = 500,
		lsp_fallback = true,
	},
})
