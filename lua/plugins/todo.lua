-- ~/.config/nvim/lua/plugins/todo.lua
-- todo-comments.nvim : highlights et navigation des commentaires speciaux
--
-- Keywords reconnus :
--   TODO   -> a faire
--   FIX    -> bug a corriger
--   HACK   -> solution temporaire
--   WARN   -> attention / danger
--   PERF   -> optimisation possible
--   NOTE   -> information importante
--   TEST   -> a tester
--
-- Keymaps :
--   ]t          -> todo suivant
--   [t          -> todo precedent
--   <leader>ft  -> Telescope : liste tous les todos
--   <leader>xt  -> Trouble   : liste tous les todos

return {
    "folke/todo-comments.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
        "folke/trouble.nvim",
    },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        require("todo-comments").setup({

            signs      = true,   -- icone dans le gutter
            sign_priority = 8,

            keywords = {
                FIX  = {
                    icon  = "! ",
                    color = "error",
                    alt   = { "FIXME", "BUG", "FIXIT", "ISSUE" },
                },
                TODO = {
                    icon  = "> ",
                    color = "info",
                },
                HACK = {
                    icon  = "~ ",
                    color = "warning",
                    alt   = { "TEMP", "TEMPORARY" },
                },
                WARN = {
                    icon  = "W ",
                    color = "warning",
                    alt   = { "WARNING", "XXX" },
                },
                PERF = {
                    icon  = "P ",
                    color = "default",
                    alt   = { "OPTIM", "OPTIMIZE", "PERFORMANCE" },
                },
                NOTE = {
                    icon  = "N ",
                    color = "hint",
                    alt   = { "INFO" },
                },
                TEST = {
                    icon  = "T ",
                    color = "test",
                    alt   = { "TESTING", "PASSED", "FAILED" },
                },
            },

            -- Couleurs (coherentes avec kanagawa wave)
            colors = {
                error   = { "DiagnosticError",   "#e82424" },
                warning = { "DiagnosticWarn",    "#ff9e3b" },
                info    = { "DiagnosticInfo",     "#7fb4ca" },
                hint    = { "DiagnosticHint",     "#98bb6c" },
                default = { "Identifier",         "#c0a36e" },
                test    = { "Statement",          "#957fb8" },
            },

            -- Style du highlight
            highlight = {
                multiline         = true,    -- supporte les todos sur plusieurs lignes
                multiline_pattern = "^.",    -- pattern de continuation
                multiline_context = 10,
                before            = "",      -- "" | "fg" | "bg"
                keyword           = "wide",  -- "fg" | "bg" | "wide" | "wide_bg" | "undercurl"
                after             = "fg",
                pattern           = [[.*<(KEYWORDS)\s*:]],
                comments_only     = true,    -- seulement dans les commentaires
                max_line_len      = 400,
                exclude           = {},
            },

            -- Recherche dans les fichiers
            search = {
                command = "rg",
                args = {
                    "--color=never",
                    "--no-heading",
                    "--with-filename",
                    "--line-number",
                    "--column",
                },
                pattern = [[\b(KEYWORDS):]],
            },
        })

        local map = vim.keymap.set

        -- Navigation entre todos
        map("n", "]t", function()
            require("todo-comments").jump_next()
        end, { desc = "Todo: next" })

        map("n", "[t", function()
            require("todo-comments").jump_prev()
        end, { desc = "Todo: previous" })

        -- Sauter vers un type specifique
        map("n", "]f", function()
            require("todo-comments").jump_next({ keywords = { "FIX", "FIXME", "BUG" } })
        end, { desc = "Todo: next FIX" })

        map("n", "[f", function()
            require("todo-comments").jump_prev({ keywords = { "FIX", "FIXME", "BUG" } })
        end, { desc = "Todo: prev FIX" })

        -- Telescope : liste tous les todos du projet
        map("n", "<leader>ft", "<cmd>TodoTelescope<CR>",
            { desc = "Telescope: todos" })

        -- Telescope : filtrer par keyword
        map("n", "<leader>fF", "<cmd>TodoTelescope keywords=FIX,FIXME,BUG<CR>",
            { desc = "Telescope: bugs only" })

        -- Trouble : todos dans le panneau diagnostics
        map("n", "<leader>xt", "<cmd>Trouble todo toggle<CR>",
            { desc = "Trouble: todos" })

        -- Trouble : seulement les FIX et WARN
        map("n", "<leader>xT", "<cmd>Trouble todo toggle filter={tag={FIX,WARN}}<CR>",
            { desc = "Trouble: urgent todos" })
    end,
}
