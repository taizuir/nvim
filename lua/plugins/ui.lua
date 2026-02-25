-- ~/.config/nvim/lua/plugins/ui.lua
-- Interface visuelle :
--   - lualine      : statusline
--   - which-key    : popup des keymaps
--   - indent-blankline : guides d'indentation
--   - barbecue     : breadcrumb (chemin > fichier > fonction)

local lualine = {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VimEnter",
    config = function()
        require("lualine").setup({
            options = {
                theme        = "auto",
                globalstatus = true,
                component_separators = { left = "|", right = "|" },
                section_separators  = { left = "",  right = "" },
                disabled_filetypes  = {
                    statusline = { "dashboard", "alpha" },
                },
            },
            sections = {
                lualine_a = { "mode" },
                lualine_b = { "branch", "diff", "diagnostics" },
                lualine_c = { { "filename", path = 1 } },
                lualine_x = { "encoding", "fileformat", "filetype" },
                lualine_y = { "progress" },
                lualine_z = { "location" },
            },
        })
    end,
}

local whichkey = {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
        local wk = require("which-key")
        wk.setup({ delay = 400, preset = "modern" })
        wk.add({
            { "<leader>d", group = "DAP / Debug" },
            { "<leader>f", group = "Telescope / Find" },
            { "<leader>g", group = "Git" },
            { "<leader>h", group = "Harpoon" },
            { "<leader>j", group = "Java" },
            { "<leader>o", group = "Overseer" },
            { "<leader>r", group = "Run" },
            { "<leader>s", group = "Surround / Swap" },
            { "<leader>t", group = "Toggle" },
            { "<leader>w", group = "Session" },
            { "<leader>x", group = "Trouble / Diagnostics" },
            { "<leader>c", group = "Code / Outline" },
            { "<leader>z", group = "Zen" },
        })
    end,
}

local indent = {
    "lukas-reineke/indent-blankline.nvim",
    main  = "ibl",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        require("ibl").setup({
            indent = { char = "|", tab_char = "|" },
            scope  = { enabled = true, show_start = true, show_end = false },
            exclude = {
                filetypes = {
                    "help", "lazy", "mason",
                    "toggleterm", "TelescopePrompt",
                },
            },
        })
    end,
}

local barbecue = {
    "utilyre/barbecue.nvim",
    version = "*",
    dependencies = {
        "SmiteshP/nvim-navic",
        "nvim-tree/nvim-web-devicons",
    },
    event = "LspAttach",
    config = function()
        require("barbecue").setup({
            show_basename  = true,
            show_dirname   = true,
            show_modified  = true,
            separator      = " > ",
            show_navic     = true,
            theme          = "auto",
            exclude_filetypes = {
                "netrw", "toggleterm", "TelescopePrompt",
                "lazy", "mason", "help",
            },
            kinds = {
                File = "F", Module = "M", Namespace = "N",
                Class = "C", Method = "m", Property = "p",
                Field = "f", Constructor = "c", Enum = "E",
                Interface = "I", Function = "fn", Variable = "v",
                Constant = "K", Struct = "S", Event = "!",
                Operator = "=", TypeParameter = "T",
            },
        })
        vim.keymap.set("n", "<leader>tb",
            function() require("barbecue.ui").toggle() end,
            { desc = "UI: toggle breadcrumb" })
    end,
}

return { lualine, whichkey, indent, barbecue }
