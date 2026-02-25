-- ~/.config/nvim/lua/plugins/outline.lua
-- Arbre des symboles LSP (fonctions, classes, variables) dans un panel lateral.
-- Utilise le LSP pour construire l'arbre en temps reel.

return {
    "hedyhli/outline.nvim",
    cmd    = { "Outline", "OutlineOpen" },
    config = function()
        require("outline").setup({
            outline_window = {
                position      = "right",
                width         = 28,
                wrap          = false,
                show_numbers  = false,
                auto_close    = false,
                auto_jump     = false,
            },
            outline_items = {
                show_symbol_details    = true,
                show_symbol_lineno     = true,
                highlight_hovered_item = true,
                auto_set_cursor        = true,
            },
            keymaps = {
                close         = { "<Esc>", "q" },
                goto_location = "<CR>",
                peek_location = "o",
                up_and_jump   = "<C-k>",
                down_and_jump = "<C-j>",
                fold          = "h",
                unfold        = "l",
                fold_all      = "W",
                unfold_all    = "E",
                fold_reset    = "R",
            },
        })

        local map = vim.keymap.set
        map("n", "<leader>co", "<cmd>Outline<CR>",
            { desc = "Outline: toggle" })
        map("n", "<leader>cO", "<cmd>OutlineFocus<CR>",
            { desc = "Outline: focus" })
    end,
}
