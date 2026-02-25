-- ~/.config/nvim/lua/plugins/treesitter.lua
return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = {
        "nvim-treesitter/nvim-treesitter-textobjects",
        "nvim-treesitter/nvim-treesitter-context",
    },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        require("nvim-treesitter.config").setup({

            ensure_installed = {
                "c", "cpp",
                "ocaml", "ocaml_interface",
                "java",
                "python",
                "rust",
                "lua",
                "bash",
                "json", "yaml", "toml",
                "html", "css",
                "markdown", "markdown_inline",
                "regex",
                "vim", "vimdoc",
                "query",
            },

            auto_install = true,

            -- Highlighting
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },

            -- Indentation
            indent = {
                enable = true,
            },

            -- Selection incrementale
            incremental_selection = {
                enable  = true,
                keymaps = {
                    init_selection    = "<C-space>",
                    node_incremental  = "<C-space>",
                    scope_incremental = "<C-s>",
                    node_decremental  = "<BS>",
                },
            },

            -- Text objects
            textobjects = {
                select = {
                    enable    = true,
                    lookahead = true,
                    keymaps = {
                        ["af"] = { query = "@function.outer",    desc = "outer function" },
                        ["if"] = { query = "@function.inner",    desc = "inner function" },
                        ["ac"] = { query = "@class.outer",       desc = "outer class" },
                        ["ic"] = { query = "@class.inner",       desc = "inner class" },
                        ["ab"] = { query = "@block.outer",       desc = "outer block" },
                        ["ib"] = { query = "@block.inner",       desc = "inner block" },
                        ["aa"] = { query = "@parameter.outer",   desc = "outer argument" },
                        ["ia"] = { query = "@parameter.inner",   desc = "inner argument" },
                        ["ai"] = { query = "@conditional.outer", desc = "outer conditional" },
                        ["ii"] = { query = "@conditional.inner", desc = "inner conditional" },
                        ["al"] = { query = "@loop.outer",        desc = "outer loop" },
                        ["il"] = { query = "@loop.inner",        desc = "inner loop" },
                    },
                },

                move = {
                    enable    = true,
                    set_jumps = true,
                    goto_next_start = {
                        ["]f"] = { query = "@function.outer",  desc = "Next function start" },
                        ["]c"] = { query = "@class.outer",     desc = "Next class start" },
                        ["]a"] = { query = "@parameter.inner", desc = "Next argument" },
                        ["]b"] = { query = "@block.outer",     desc = "Next block start" },
                    },
                    goto_next_end = {
                        ["]F"] = { query = "@function.outer",  desc = "Next function end" },
                        ["]C"] = { query = "@class.outer",     desc = "Next class end" },
                    },
                    goto_previous_start = {
                        ["[f"] = { query = "@function.outer",  desc = "Prev function start" },
                        ["[c"] = { query = "@class.outer",     desc = "Prev class start" },
                        ["[a"] = { query = "@parameter.inner", desc = "Prev argument" },
                        ["[b"] = { query = "@block.outer",     desc = "Prev block start" },
                    },
                    goto_previous_end = {
                        ["[F"] = { query = "@function.outer",  desc = "Prev function end" },
                        ["[C"] = { query = "@class.outer",     desc = "Prev class end" },
                    },
                },

                swap = {
                    enable = true,
                    swap_next = {
                        ["<leader>sa"] = { query = "@parameter.inner", desc = "Swap next arg" },
                    },
                    swap_previous = {
                        ["<leader>sA"] = { query = "@parameter.inner", desc = "Swap prev arg" },
                    },
                },
            },
        })

        -- Contexte : affiche la fonction/classe courante en haut
        require("treesitter-context").setup({
            enable              = true,
            max_lines           = 4,
            min_window_height   = 20,
            line_numbers        = true,
            multiline_threshold = 1,
            trim_scope          = "outer",
            mode                = "cursor",
            separator           = "-",
            zindex              = 20,
        })

        vim.keymap.set("n", "<leader>tc",
            "<cmd>TSContextToggle<CR>",
            { desc = "Treesitter: toggle context" })
    end,
}
