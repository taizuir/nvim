-- ~/.config/nvim/lua/plugins/animations.lua
-- Pack "animations" pour Neovim, à placer dans ton dossier plugins/ (lazy.nvim)
--
-- Contenu :
--   1. smear-cursor.nvim   -> curseur qui laisse une traînée fluide (style Neovide)
--   2. tiny-glimmer.nvim   -> flash/pulse sur yank, paste, undo/redo, ET sur write
--   3. neoscroll.nvim      -> scroll fluide (au lieu de sauter ligne par ligne)
--   4. cellular-automaton.nvim -> easter egg (feu d'artifice / jeu de la vie) pour le fun

return {

	-- 1. Curseur avec effet de traînée
	{
		"sphamba/smear-cursor.nvim",
		event = "VeryLazy",
		opts = {
			smear_between_buffers = true,
			smear_between_neighbor_lines = true,
			scroll_buffer_space = true,
			legacy_computing_symbols_support = false, -- true si ta police supporte les block chars
			smear_insert_mode = true, -- anime aussi pendant que tu écris
			cursor_color = "none", -- garde la couleur native du curseur
			stiffness = 0.6, -- + petit = traînée plus longue
			trailing_stiffness = 0.3,
			never_draw_over_target = true,
		},
	},

	-- 2. Flash/pulse sur les actions de texte (yank, paste, undo, write)
	{
		"rachartier/tiny-glimmer.nvim",
		event = "VeryLazy",
		priority = 10,
		opts = {
			overwrite = {
				auto_map = true, -- anime déjà yank / paste / undo / redo automatiquement
			},
			default_animation = "fade",
		},
	},

	-- 3. Scroll fluide
	{
		"karb94/neoscroll.nvim",
		event = "VeryLazy",
		opts = {
			mappings = { "<C-u>", "<C-d>", "<C-b>", "<C-f>", "zt", "zz", "zb" },
			hide_cursor = true,
			stop_eof = true,
			easing = "quadratic",
			performance_mode = false,
		},
	},

	-- 4. Bonus fun : animations easter-egg (à lancer manuellement, ex: :CellularAutomaton make_it_rain)
	{
		"Eandrju/cellular-automaton.nvim",
		cmd = "CellularAutomaton",
		keys = {
			{ "<leader>fml", "<cmd>CellularAutomaton make_it_rain<cr>", desc = "Animation: pluie de texte" },
			{ "<leader>fmg", "<cmd>CellularAutomaton game_of_life<cr>", desc = "Animation: jeu de la vie" },
		},
	},
}
