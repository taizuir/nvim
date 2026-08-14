return {
	"saecki/crates.nvim",
	event = { "BufRead Cargo.toml" },
	opts = {
		completion = {
			-- makes crate versions show up as a blink.cmp source in Cargo.toml
			crates = { enabled = true },
		},
		lsp = {
			enabled = true,
			on_attach = function(_, bufnr)
				local crates = require("crates")
				local function map(keys, func, desc)
					vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "Crates: " .. desc })
				end

				map("<leader>cu", crates.update_crate, "Update crate")
				map("<leader>cU", crates.upgrade_crate, "Upgrade crate")
				map("<leader>cA", crates.upgrade_all_crates, "Upgrade all crates")
				map("<leader>cD", crates.show_popup, "Show crate info")
				map("<leader>cF", crates.show_features_popup, "Show features")
			end,
			actions = true,
			completion = true,
			hover = true,
		},
	},
}
