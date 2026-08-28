return {
	"ahmedkhalf/project.nvim",
	event = "VeryLazy",
	opts = { manual_mode = false, detection_methods = { "lsp", "pattern" } },
	config = function(_, opts)
		require("project_nvim").setup(opts)
		require("telescope").load_extension("projects")
	end,
	keys = { { "<leader>fp", "<cmd>Telescope projects<cr>", desc = "Changer de projet" } },
}
