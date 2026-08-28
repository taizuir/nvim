-- add this to your lua/plugins.lua, lua/plugins/init.lua,  or the file you keep your other plugins:
return {
	"numToStr/Comment.nvim",
	opts = {
		toggler = {
			--     ---Line-comment toggle keymap
			line = "gcc",
			--     ---Block-comment toggle keymap
			block = "gbc",
			--   -- add any options here
		},
		--
	},
}
