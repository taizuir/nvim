-- add this to your lua/plugins.lua, lua/plugins/init.lua,  or the file you keep your other plugins:
return {
	'numToStr/Comment.nvim',
	opts = {
		toggler = {
			--     ---Line-comment toggle keymap
			line = 'c',
			--     ---Block-comment toggle keymap
			block = 'cc',
			--   -- add any options here
		}
		--
	}
}
