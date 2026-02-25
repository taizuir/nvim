-- ~/.config/nvim/lua/plugins/session.lua
-- Sauvegarde et restauration automatique des sessions par dossier.
-- Chaque projet retrouve son etat exact : buffers, splits, fenetres.

return {
    "rmagatti/auto-session",
    lazy = false,
    config = function()
        require("auto-session").setup({
            auto_save_enabled    = true,
            auto_restore_enabled = true,
            auto_session_root_dir = vim.fn.stdpath("data") .. "/sessions/",
            auto_restore_lazy_delay_enabled = true,
            bypass_session_save_file_types = {
                "alpha", "dashboard", "neo-tree",
                "lazy", "mason", "toggleterm",
            },
            session_lens = {
                load_on_setup = true,
                theme_conf    = { border = true },
                previewer     = false,
            },
        })

        local map = vim.keymap.set
        map("n", "<leader>fs", "<cmd>SessionSearch<CR>",  { desc = "Session: search" })
        map("n", "<leader>ws", "<cmd>SessionSave<CR>",    { desc = "Session: save" })
        map("n", "<leader>wr", "<cmd>SessionRestore<CR>", { desc = "Session: restore" })
        map("n", "<leader>wd", "<cmd>SessionDelete<CR>",  { desc = "Session: delete" })
    end,
}
