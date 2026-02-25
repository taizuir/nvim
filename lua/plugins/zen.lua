-- ~/.config/nvim/lua/plugins/zen.lua
-- Mode concentration : masque tout sauf le buffer courant.
-- Twilight dimme le code en dehors du curseur.

return {
    "folke/zen-mode.nvim",
    dependencies = { "folke/twilight.nvim" },
    cmd    = "ZenMode",
    config = function()
        require("zen-mode").setup({
            window = {
                backdrop = 0.92,
                width    = 0.75,
                height   = 1,
                options  = {
                    signcolumn     = "no",
                    number         = false,
                    relativenumber = false,
                    cursorline     = false,
                    foldcolumn     = "0",
                    list           = false,
                },
            },
            plugins = {
                options  = { enabled = true, laststatus = 0 },
                twilight = { enabled = true },
                gitsigns = { enabled = false },
            },
        })

        require("twilight").setup({
            dimming = { alpha = 0.25 },
            context = 15,
            expand  = { "function", "method", "table", "if_statement" },
        })

        vim.keymap.set("n", "<leader>z", "<cmd>ZenMode<CR>",
            { desc = "Zen: toggle" })
    end,
}
