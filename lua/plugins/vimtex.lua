return {
	"lervag/vimtex",
	lazy = false, -- vimtex needs early loading to detect .tex files correctly
	ft = { "tex", "plaintex", "bib" },
	init = function()
		-- these vim.g options must be set BEFORE the plugin loads, hence `init`
		vim.g.vimtex_view_method = "zathura" -- swap for your PDF viewer, e.g. "skim", "sioyek"
		vim.g.vimtex_quickfix_mode = 0
		vim.g.vimtex_compiler_method = "latexmk"
		-- default keymaps live under <localleader>l (ll compile, lv view, lc clean, etc.)
		-- — no conflict with iron.nvim's <localleader>s*/m*/cl since the full
		-- sequences differ (vimtex is always <localleader>l + letter)
	end,
}
