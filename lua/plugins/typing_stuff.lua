return {
	{
		"NStefan002/speedtyper.nvim",
		branch = "v2",
		lazy = false,
	},
	{
		"nvzone/typr",
		dependencies = "nvzone/volt",
		opts = {},
		cmd = { "Typr", "TyprStats" },
	},
	{
		"saltytine/typestats.nvim",
		name = "typestats",
		config = function()
			vim.o.statusline = "%f %h%m%r %=%{v:lua.TypeStats.statusline()} %l,%c %p%%"
		end,
	},
}
