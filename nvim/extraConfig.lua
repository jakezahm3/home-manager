-- Provider configuration
vim.g.python3_host_prog = "@PYTHON3_HOST_PROG@"
vim.g.node_host_prog = vim.fn.exepath('neovim-node-host')
vim.g.loaded_python3_provider = nil;
vim.g.loaded_node_provider = nil;
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
    markdown = { "prettierd" },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
})
