-- ~/.config/nvim/lua/plugins/comment.lua
-- Commenter / decommenter avec gc.
-- Detecte automatiquement le style selon le langage (treesitter).

return {
    "echasnovski/mini.comment",
    version = "*",
    dependencies = {
        "JoosepAlviste/nvim-ts-context-commentstring",
    },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        require("ts_context_commentstring").setup({ enable_autocmd = false })

        require("mini.comment").setup({
            options = {
                custom_commentstring = function()
                    return require("ts_context_commentstring.internal")
                               .calculate_commentstring()
                        or vim.bo.commentstring
                end,
            },
            mappings = {
                comment        = "gc",
                comment_line   = "gcc",
                comment_visual = "gc",
                textobject     = "gc",
            },
        })
    end,
}
