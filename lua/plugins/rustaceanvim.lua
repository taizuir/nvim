return {
	"mrcjkb/rustaceanvim",
	version = "^6", -- pin to major version, avoids surprise breaking updates
	lazy = false, -- rustaceanvim needs to load before a rust file triggers FileType
	ft = { "rust" },
	config = function()
		vim.g.rustaceanvim = {
			-- these override/merge with the shared LSP config in lsp.lua,
			-- so blink.cmp completion still works for rust-analyzer
			server = {
				capabilities = require("blink.cmp").get_lsp_capabilities(),
				default_settings = {
					["rust-analyzer"] = {
						cargo = { allFeatures = true },
						checkOnSave = true,
						check = { command = "clippy" },
					},
				},
			},
		}

		vim.keymap.set("n", "<leader>rl", function()
			vim.cmd.RustLsp("run")
		end, { desc = "Rust: run" })
		vim.keymap.set("n", "<leader>rt", function()
			vim.cmd.RustLsp("testables")
		end, { desc = "Rust: run tests" })
		vim.keymap.set("n", "<leader>rd", function()
			vim.cmd.RustLsp("debuggables")
		end, { desc = "Rust: debug" })
		vim.keymap.set("n", "<leader>rk", function()
			vim.cmd.RustLsp({ "hover", "actions" })
		end, { desc = "Rust: hover actions" })
	end,
}
