return{
	"nvim-treesitter/nvim-treesitter",
	branch = 'master', 
	lazy = false,
	build = ":TSUpdate",
	opts=
	{
	  ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "elixir", "heex", "javascript", "html" ,'python','java','cpp'},
          sync_install = false,
          highlight = { enable = true },
          indent = { enable = true }
  }
}
