-- ~/.config/nvim/lua/plugins/gitsigns.lua
-- Signes git dans le gutter (+ ajout, ~ modif, _ suppr).
-- Stage/reset de hunks directement depuis Neovim.
-- Blame inline sur la ligne courante.
-- Les utilitaires git avances (LazyGit, DiffView, Neogit) sont dans git.lua.

return {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        require("gitsigns").setup({
            signs = {
                add          = { text = "+" },
                change       = { text = "~" },
                delete       = { text = "_" },
                topdelete    = { text = "-" },
                changedelete = { text = "%" },
                untracked    = { text = "|" },
            },
            current_line_blame = false,
            current_line_blame_opts = {
                virt_text     = true,
                virt_text_pos = "eol",
                delay         = 800,
            },
            on_attach = function(bufnr)
                local gs  = package.loaded.gitsigns
                local map = function(mode, keys, func, desc)
                    vim.keymap.set(mode, keys, func,
                        { buffer = bufnr, desc = "Git: " .. desc })
                end

                -- Navigation
                map("n", "]g", function()
                    if vim.wo.diff then return "]g" end
                    vim.schedule(function() gs.next_hunk() end)
                    return "<Ignore>"
                end, "Next hunk")

                map("n", "[g", function()
                    if vim.wo.diff then return "[g" end
                    vim.schedule(function() gs.prev_hunk() end)
                    return "<Ignore>"
                end, "Prev hunk")

                -- Actions
                map("n", "<leader>gs", gs.stage_hunk,   "Stage hunk")
                map("n", "<leader>gr", gs.reset_hunk,   "Reset hunk")
                map("n", "<leader>gS", gs.stage_buffer, "Stage buffer")
                map("n", "<leader>gR", gs.reset_buffer, "Reset buffer")
                map("n", "<leader>gp", gs.preview_hunk, "Preview hunk")
                map("n", "<leader>gb", gs.toggle_current_line_blame, "Toggle blame")
            end,
        })
    end,
}
