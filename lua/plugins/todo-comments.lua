return {
	"folke/todo-comments.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	event = { "BufReadPost", "BufNewFile" },
	opts = {
		signs = true,
		keywords = {
			FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT" } },
			TODO = { icon = " ", color = "info" },
			HACK = { icon = " ", color = "warning" },
			WARN = { icon = " ", color = "warning", alt = { "WARNING" } },
			PERF = { icon = " ", color = "hint", alt = { "OPTIM", "PERFORMANCE" } },
			NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
		},
	},
	keys = {
		{
			"]t",
			function()
				require("todo-comments").jump_next()
			end,
			desc = "TODO suivant",
		},
		{
			"[t",
			function()
				require("todo-comments").jump_prev()
			end,
			desc = "TODO précédent",
		},
		{ "<leader>xt", "<cmd>TodoTrouble<cr>", desc = "TODOs (dans Trouble)" },
		{ "<leader>xT", "<cmd>TodoTelescope<cr>", desc = "Chercher les TODOs" },
	},
}
