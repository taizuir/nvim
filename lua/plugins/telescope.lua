return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.8",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		local telescope = require("telescope")
		local actions   = require("telescope.actions")
		local builtin   = require("telescope.builtin")

		telescope.setup({
			defaults = {
				path_display     = { "smart" },
				sorting_strategy = "ascending",
				layout_config    = {
					horizontal = { prompt_position = "top", preview_width = 0.55 },
				},
				mappings = {
					i = {
						["<C-k>"] = actions.move_selection_previous,
						["<C-j>"] = actions.move_selection_next,
						["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
						["<Esc>"] = actions.close,
					},
				},
			},
		})

		telescope.load_extension("fzf")

		local map = vim.keymap.set

		-- -- Fichiers ----------------------------------
		map("n", "<leader>ff",  builtin.find_files,      { desc = "Telescope: find files" })
		map("n", "<leader>fg",  builtin.live_grep,       { desc = "Telescope: live grep" })
		map("n", "<leader>fb",  builtin.buffers,         { desc = "Telescope: buffers" })
		map("n", "<leader>fr",  builtin.oldfiles,        { desc = "Telescope: recent files" })

		-- -- Aide / commandes --------------------------
		map("n", "<leader>fh",  builtin.help_tags,       { desc = "Telescope: help tags" })
		map("n", "<leader>fc",  builtin.commands,        { desc = "Telescope: commands" })
		map("n", "<leader>fch", builtin.command_history, { desc = "Telescope: command history" })

		-- -- Grep / recherche --------------------------
		-- NOTE: la ligne originale <le <leader>fd tait invalide (syntaxe casse)
		-- remplace par <leader>fw (word) et <leader>fs (string)
		map("n", "<leader>fw", function()
			builtin.grep_string({ search = vim.fn.expand("<cWORD>") })
		end, { desc = "Telescope: grep word under cursor" })

		map("n", "<leader>fs", function()
			builtin.grep_string({ search = vim.fn.input("Grep > ") })
		end, { desc = "Telescope: grep string" })

		-- -- Diagnostics (utilis aussi dans debug.lua) -
		map("n", "<leader>fd",  builtin.diagnostics,     { desc = "Telescope: diagnostics" })

		-- -- LSP navigation (provider pour lsp.lua) ----
		-- Les keymaps grr / grd / gri / grt / gO / gW
		-- sont dfinis dans lsp.lua via LspAttach.
		-- Telescope est le backend -- aucun doublon ici.
	end,
}
