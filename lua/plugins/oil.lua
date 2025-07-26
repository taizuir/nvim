return{
  'stevearc/oil.nvim',
  ---@module 'oil'
  ---@type oil.SetupOpts
  
  -- Optional dependencies
  dependencies = { { 'nvim-tree/nvim-web-devicons', opts = {} } },
  -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
  -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
  lazy = false,
  config= function()
	require('oil').setup({
		default_file_explorer=true,
		columns={ },
		view_options={show_hidden=true},
		vim.keymap.set('n','<leader>o','<CMD>Oil<CR>'),
  	
		vim.keymap.set('n','<leader>oo',require('oil').toggle_float)
	}
  )end
}

---- your configuration comes here
    -- or leave it empty to use the default settings
    --refer to the configuration section below
