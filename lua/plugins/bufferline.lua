return {
	"akinsho/bufferline.nvim",
	version = "*",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	event = "VeryLazy",
	opts = {
		options = {
			diagnostics = "nvim_lsp",
			always_show_bufferline = true,
			separator_style = "slant",
		},
	},
	keys = {
		{ "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Buffer précédent" },
		{ "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Buffer suivant" },
		{ "<leader>bp", "<cmd>BufferLineTogglePin<cr>", desc = "Épingler le buffer" },
		{ "<leader>bc", "<cmd>BufferLineCloseOthers<cr>", desc = "Fermer les autres buffers" },
	},
}
