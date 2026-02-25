-- ~/.config/nvim/lua/plugins/editing.lua
--
-- Plugins d'edition :
--   1. echasnovski/mini.surround  -> entourer / supprimer / remplacer des surrounds
--   2. Wansmer/treesj             -> split / join intelligent via treesitter
--
-- Keymaps :
--   Surround  : sa / sd / sr / sf / sF / sh
--   Split/Join: gS  -> split sur plusieurs lignes
--               gJ  -> join sur une ligne
--               gT  -> toggle (split si une ligne, join si plusieurs)

-- =====================================================
-- 1. MINI.SURROUND
-- =====================================================
local surround = {
    "echasnovski/mini.surround",
    version = "*",
    event   = { "BufReadPre", "BufNewFile" },
    config  = function()
        require("mini.surround").setup({
            n_lines            = 20,
            highlight_duration = 500,

            mappings = {
                add            = "sa",
                delete         = "sd",
                replace        = "sr",
                find           = "sf",
                find_left      = "sF",
                highlight      = "sh",
                update_n_lines = "sn",
            },

            custom_surroundings = {
                -- Parentheses avec espaces :  ( texte )
                ["("] = {
                    input  = { "%b()", "^.%s*().-()%s*.$" },
                    output = { left = "( ", right = " )" },
                },
                -- Commentaire OCaml :  (* texte *)
                ["o"] = {
                    input  = { "%(%*().-()%*%)" },
                    output = { left = "(* ", right = " *)" },
                },
                -- Commentaire C :  /* texte */
                ["c"] = {
                    input  = { "/%*().-()%*/" },
                    output = { left = "/* ", right = " */" },
                },
                -- Balise HTML/JSX
                ["t"] = {
                    input  = { "<(%w-)%f[^%w][^>]->.-</%1>", "^<.->().-()</[^/]->$" },
                    output = function()
                        local tag = vim.fn.input("Tag: ")
                        return {
                            left  = "<" .. tag .. ">",
                            right = "</" .. tag .. ">",
                        }
                    end,
                },
            },
        })
    end,
}

-- =====================================================
-- 2. TREESJ  (splitjoin intelligent via treesitter)
-- =====================================================
local splitjoin = {
    "Wansmer/treesj",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event        = { "BufReadPre", "BufNewFile" },
    config       = function()
        require("treesj").setup({
            -- Utilise les keymaps definis manuellement ci-dessous
            use_default_keymaps = false,

            -- Verifie si la transformation est possible avant de l'appliquer
            check_syntax_error = true,

            -- Longueur max pour autoriser un join sur une ligne
            max_join_length = 120,

            -- Curseur reste sur la meme position apres split/join
            cursor_behavior = "hold",

            -- Ouvre le fold si le noeud est dans un fold
            notify = true,
            langs  = {
                -- Langages actifs dans ta config
                lua        = {},
                python     = {},
                javascript = {},
                typescript = {},
                c          = {},
                cpp        = {},
                rust       = {},
                ocaml      = {},
                java       = {},
                html       = {},
                json       = {},
                yaml       = {},
                toml       = {},
            },
        })

        local map = vim.keymap.set

        -- gS  -> Split : une ligne -> plusieurs lignes
        --   { a = 1, b = 2 }
        --   ->
        --   {
        --     a = 1,
        --     b = 2,
        --   }
        map("n", "gS", "<cmd>TSJSplit<CR>",  { desc = "SplitJoin: split" })

        -- gJ  -> Join : plusieurs lignes -> une ligne
        --   {
        --     a = 1,
        --     b = 2,
        --   }
        --   ->
        --   { a = 1, b = 2 }
        map("n", "gJ", "<cmd>TSJJoin<CR>",   { desc = "SplitJoin: join" })

        -- gT  -> Toggle : split si sur une ligne, join si sur plusieurs
        map("n", "gT", "<cmd>TSJToggle<CR>", { desc = "SplitJoin: toggle" })
    end,
}

return { surround, splitjoin }
