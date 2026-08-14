return {
	"nvim-treesitter/nvim-treesitter",
	branch = "master",
	lazy = false,
	build = ":TSUpdate",
	opts = {
		ensure_installed = { "c", "lua", "vim", "vimdoc", "html", "python", "java", "cpp", "rust" },
		sync_install = false,
		highlight = { enable = true },
		indent = { enable = true },
	},
}
