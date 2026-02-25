-- ~/.config/nvim/lua/plugins/colorscheme.lua
--
-- Kanagawa wave + fond transparent + blur via compositor
--
-- PREREQUIS pour le blur :
--   Linux (X11) : picom avec backend glx
--     picom.conf -> blur-method = "dual_kawase"; blur-strength = 8;
--     window-rule -> blur-background = true pour class = "nvim" / "Alacritty" / etc.
--
--   Linux (Wayland) : hyprland
--     windowrulev2 = blur, class:^(kitty|alacritty|foot)$
--     decoration { blur { enabled = true; size = 8; passes = 3 } }
--
--   macOS : transparent = true suffit, le blur est natif dans Terminal/iTerm2/Alacritty
--
--   Windows Terminal : activez "Acrylic" ou "Mica" dans les parametres du terminal

return {
    "rebelot/kanagawa.nvim",
    lazy     = false,
    priority = 1000,

    config = function()
        require("kanagawa").setup({
            compile        = false,
            undercurl      = true,
            commentStyle   = { italic = true },
            functionStyle  = {},
            keywordStyle   = { italic = true },
            statementStyle = { bold = true },
            typeStyle      = {},
            -- TRANSPARENT : retire le fond de Neovim
            -- Le terminal/compositor affiche ce qu'il y a derriere
            transparent    = true,
            dimInactive    = false,
            terminalColors = true,

            colors = {
                theme = {
                    all = {
                        ui = {
                            bg_gutter = "none",
                        },
                    },
                },
            },

            overrides = function(colors)
                local theme = colors.theme
                return {
                    -- Fond principal transparent
                    Normal         = { bg = "none" },
                    NormalNC       = { bg = "none" },
                    NormalFloat    = { bg = "none" },
                    FloatBorder    = { bg = "none" },
                    FloatTitle     = { bg = "none" },

                    -- Statusline et tabline
                    StatusLine     = { bg = "none" },
                    StatusLineNC   = { bg = "none" },
                    TabLine        = { bg = "none" },
                    TabLineFill    = { bg = "none" },
                    TabLineSel     = { bg = "none" },

                    -- Winbar (barbecue)
                    WinBar         = { bg = "none" },
                    WinBarNC       = { bg = "none" },

                    -- Sidebar / panneaux (Outline, Trouble, DiffView...)
                    SignColumn     = { bg = "none" },
                    FoldColumn     = { bg = "none" },
                    LineNr         = { bg = "none" },
                    CursorLineNr   = { bg = "none" },

                    -- Popup de completion : leger fond semi-transparent
                    Pmenu          = { fg = theme.ui.fg, bg = "none" },
                    PmenuSel       = { fg = "none", bg = theme.ui.bg_p2 },
                    PmenuSbar      = { bg = theme.ui.bg_m1 },
                    PmenuThumb     = { bg = theme.ui.bg_p2 },

                    -- Telescope : fenetres transparentes
                    TelescopeTitle         = { fg = theme.ui.special, bold = true },
                    TelescopeNormal        = { bg = "none" },
                    TelescopePromptNormal  = { bg = "none" },
                    TelescopePromptBorder  = { fg = theme.ui.bg_p1, bg = "none" },
                    TelescopeResultsNormal = { fg = theme.ui.fg_dim, bg = "none" },
                    TelescopeResultsBorder = { fg = theme.ui.bg_m1, bg = "none" },
                    TelescopePreviewNormal = { bg = "none" },
                    TelescopePreviewBorder = { fg = theme.ui.bg_dim, bg = "none" },

                    -- Indentation guides (ibl)
                    IblIndent      = { fg = theme.ui.bg_p1, bg = "none" },
                    IblScope       = { fg = theme.ui.special, bg = "none" },

                    -- Divers
                    EndOfBuffer    = { bg = "none" },
                    VertSplit      = { bg = "none" },
                    WinSeparator   = { bg = "none" },
                }
            end,

            theme      = "wave",
            background = { dark = "wave", light = "lotus" },
        })

        vim.cmd("colorscheme kanagawa")

        -- S'assure que le fond reste transparent apres un colorscheme reload
        vim.api.nvim_create_autocmd("ColorScheme", {
            pattern  = "*",
            callback = function()
                vim.api.nvim_set_hl(0, "Normal",      { bg = "none" })
                vim.api.nvim_set_hl(0, "NormalNC",    { bg = "none" })
                vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
                vim.api.nvim_set_hl(0, "SignColumn",  { bg = "none" })
                vim.api.nvim_set_hl(0, "StatusLine",  { bg = "none" })
                vim.api.nvim_set_hl(0, "WinBar",      { bg = "none" })
            end,
        })
    end,
}
