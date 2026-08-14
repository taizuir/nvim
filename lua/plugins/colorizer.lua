return {
	"NvChad/nvim-colorizer.lua",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		filetypes = { "*" }, -- enable everywhere; remove "*" and list filetypes to scope it down
		user_default_options = {
			RGB = true,
			RRGGBB = true,
			names = false, -- don't highlight color words like "red" — noisy outside CSS
			RRGGBBAA = true,
			rgb_fn = true,
			hsl_fn = true,
			css = true,
			css_fn = true,
			mode = "background",
		},
	},
}
