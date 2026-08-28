return {
	"nvim-telescope/telescope-frecency.nvim",
	dependencies = { "nvim-telescope/telescope.nvim" },
	keys = { { "<leader>fr", "<cmd>Telescope frecency<cr>", desc = "Fichiers (frécence)" } },
	config = function()
		require("telescope").load_extension("frecency")
	end,
}
