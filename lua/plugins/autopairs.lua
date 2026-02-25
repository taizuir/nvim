-- ~/.config/nvim/lua/plugins/autopairs.lua
-- Fermeture automatique des paires et des balises HTML/JSX.
--   - nvim-autopairs : ( { [ " ' -> ferme automatiquement
--   - nvim-ts-autotag : <div> -> </div> auto + renommage des deux balises

local autopairs = {
    "windwp/nvim-autopairs",
    event        = "InsertEnter",
    config = function()
        local ap   = require("nvim-autopairs")
        local Rule = require("nvim-autopairs.rule")

        ap.setup({
            check_ts = true,
            ts_config = {
                lua    = { "string" },
                python = { "string" },
                c      = { "string" },
            },
            disable_filetype = { "TelescopePrompt", "vim" },
            fast_wrap = {
                map     = "<M-e>",
                chars   = { "{", "[", "(", '"', "'" },
                pattern = [=[[%'%"%>%]%)%}%,]]=],
                keys    = "qwertyuiopzxcvbnmasdfghjkl",
                highlight = "Search",
            },
        })

        -- Espace dans les accolades/crochets/parentheses
        ap.add_rules({
            Rule(" ", " ")
                :with_pair(function(opts)
                    local pair = opts.line:sub(opts.col - 1, opts.col)
                    return vim.tbl_contains({ "()", "[]", "{}" }, pair)
                end),
        })

        -- Integration blink.cmp / nvim-cmp
        local ok, cmp = pcall(require, "cmp")
        if ok then
            local cmp_ap = require("nvim-autopairs.completion.cmp")
            cmp.event:on("confirm_done", cmp_ap.on_confirm_done())
        end
    end,
}

local autotag = {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        require("nvim-ts-autotag").setup({
            opts = {
                enable_close          = true,
                enable_rename         = true,
                enable_close_on_slash = false,
            },
            per_filetype = {
                ["html"]       = { enable_close = true },
                ["javascript"] = { enable_close = true },
                ["typescript"] = { enable_close = true },
            },
        })
    end,
}

return { autopairs, autotag }
