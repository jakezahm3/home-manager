require("nvchad.configs.lspconfig").defaults()

--local coq = require("coq")
--local nvlsp = require("nvchad.configs.lspconfig")

local servers = {
	"html",
	"cssls",
	"lua_ls",
	"bashls",
	"yamlls",
	"pyright",
	"nixd",
	"texlab",
	"tinymist",
	"tombi",
	"jsonls",
}

-- for _, lsp in ipairs(servers) do
-- 	vim.lsp.config(
-- 		lsp,
-- 		coq.lsp_ensure_capabilities({
-- 			on_attach = nvlsp.on_attach,
-- 			on_init = nvlsp.on_init,
-- 			capabilities = nvlsp.capabilities,
-- 		})
-- 	)
-- end

vim.lsp.enable(servers)
