return {
	"neovim/nvim-lspconfig",
	dependencies = {
		{ "mason-org/mason.nvim",                 opts = {} },
		"mason-org/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		{ "j-hui/fidget.nvim",                    opts = {} },
		"saghen/blink.cmp",
		-- telescope.nvim est le provider pour les keymaps LSP
		"nvim-telescope/telescope.nvim",
	},

	config = function()

		-- ---------------------------------------------
		-- Keymaps  --  dfinis au LspAttach (buffer-local)
		-- Prfixe  : gr*  (navigation), <leader>t* (toggle)
		-- telescope.lua gre <leader>f* (recherche globale)
		-- debug.lua gre   <leader>d* (DAP)
		-- ---------------------------------------------
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
			callback = function(event)
				local map = function(keys, func, desc, mode)
					mode = mode or "n"
					vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
				end
				local builtin = require("telescope.builtin")

				-- Navigation (provider : Telescope)
				map("grd", builtin.lsp_definitions,              "[G]oto [D]efinition")
				map("grr", builtin.lsp_references,               "[G]oto [R]eferences")
				map("gri", builtin.lsp_implementations,          "[G]oto [I]mplementation")
				map("grt", builtin.lsp_type_definitions,         "[G]oto [T]ype definition")
				map("grD", vim.lsp.buf.declaration,              "[G]oto [D]eclaration")
				map("gO",  builtin.lsp_document_symbols,         "Document [S]ymbols")
				map("gW",  builtin.lsp_dynamic_workspace_symbols,"Workspace [S]ymbols")

				-- Actions
				map("grn", vim.lsp.buf.rename,       "[R]e[n]ame")
				map("gra", vim.lsp.buf.code_action,  "[C]ode [A]ction", { "n", "x" })
				map("K",   vim.lsp.buf.hover,        "Hover documentation")

				-- -- Compat nvim 0.10 / 0.11 -------------
				---@param client vim.lsp.Client
				---@param method vim.lsp.protocol.Method
				---@param bufnr? integer
				---@return boolean
				local function client_supports_method(client, method, bufnr)
					if vim.fn.has("nvim-0.11") == 1 then
						return client:supports_method(method, bufnr)
					else
						return client.supports_method(method, { bufnr = bufnr })
					end
				end

				-- Highlight des rfrences sous le curseur
				local client = vim.lsp.get_client_by_id(event.data.client_id)
				if client and client_supports_method(
					client,
					vim.lsp.protocol.Methods.textDocument_documentHighlight,
					event.buf
				) then
					local hl = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
					vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
						buffer = event.buf, group = hl,
						callback = vim.lsp.buf.document_highlight,
					})
					vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
						buffer = event.buf, group = hl,
						callback = vim.lsp.buf.clear_references,
					})
					vim.api.nvim_create_autocmd("LspDetach", {
						group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
						callback = function(e)
							vim.lsp.buf.clear_references()
							vim.api.nvim_clear_autocmds({ group = "lsp-highlight", buffer = e.buf })
						end,
					})
				end

				-- Inlay hints toggle
				if client and client_supports_method(
					client,
					vim.lsp.protocol.Methods.textDocument_inlayHint,
					event.buf
				) then
					map("<leader>th", function()
						vim.lsp.inlay_hint.enable(
							not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf })
						)
					end, "[T]oggle Inlay [H]ints")
				end
			end,
		})

		-- ---------------------------------------------
		-- Diagnostics
		-- ---------------------------------------------
		vim.diagnostic.config({
			severity_sort = true,
			float         = { border = "rounded", source = "if_many" },
			underline     = { severity = vim.diagnostic.severity.ERROR },
			signs         = {
				text = {
					[vim.diagnostic.severity.ERROR] = "E ",
					[vim.diagnostic.severity.WARN]  = "W ",
					[vim.diagnostic.severity.INFO]  = "I ",
					[vim.diagnostic.severity.HINT]  = "H ",
				},
			},
			virtual_text = {
				source  = "if_many",
				spacing = 2,
				format  = function(d) return d.message end,
			},
		})

		-- ---------------------------------------------
		-- Capabilities (blink.cmp)
		-- ---------------------------------------------
		local capabilities = require("blink.cmp").get_lsp_capabilities()

		-- ---------------------------------------------
		-- Serveurs LSP
		-- IMPORTANT : jdtls (Java) est absent intentionnellement --
		-- il est gr exclusivement par ftplugin/java.lua via nvim-jdtls
		-- ---------------------------------------------
		local servers = {
			--Rust
			rust_analyzer={},
			-- C / C++
			clangd   = {},

			-- Python
			pyright  = {},

			-- OCaml  ->  opam install ocaml-lsp-server
			ocamllsp = {
				settings = {
					codelens            = { enable = true },
					inlayHints          = { enable = true },
					syntaxDocumentation = { enable = true },
				},
			},

			-- Lua
			lua_ls   = {
				settings = {
					Lua = {
						completion  = { callSnippet = "Replace" },
						diagnostics = { disable = { "missing-fields" } },
					},
				},
			},
		}

		-- ---------------------------------------------
		-- Mason : outils  installer automatiquement
		-- ---------------------------------------------
		local ensure_installed = vim.tbl_keys(servers or {})
		vim.list_extend(ensure_installed, {
			"stylua",  -- formatter Lua
			"black",   -- formatter Python
			"pyright"
		})

		require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

		-- ---------------------------------------------
		-- mason-lspconfig handlers
		-- ---------------------------------------------
		require("mason-lspconfig").setup({
			ensure_installed       = {},
			automatic_installation = false,
			handlers = {
				function(server_name)
					-- jdtls ignor ici -- gr par ftplugin/java.lua
					if server_name == "jdtls" then return end

					local server = servers[server_name] or {}
					server.capabilities = vim.tbl_deep_extend(
						"force", {}, capabilities, server.capabilities or {}
					)
					require("lspconfig")[server_name].setup(server)
				end,
			},
		})
	end,
}
