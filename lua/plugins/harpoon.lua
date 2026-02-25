-- ~/.config/nvim/lua/plugins/harpoon.lua
-- Harpoon 2 : marquer et sauter entre fichiers frequents (max 4-5)
-- Pense a lui comme des "favoris persistants" par projet

return {
    "ThePrimeagen/harpoon",
    branch       = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        local harpoon = require("harpoon")

        harpoon:setup({
            settings = {
                save_on_toggle = true,   -- sauvegarde quand on ferme le menu
                sync_on_ui_close = true,
            },
        })

        local map = vim.keymap.set

        -- Ajouter le fichier courant a harpoon
        map("n", "<leader>ha", function()
            harpoon:list():add()
            vim.notify("Harpoon: added " .. vim.fn.expand("%:t"), vim.log.levels.INFO)
        end, { desc = "Harpoon: add file" })

        -- Ouvrir le menu harpoon (liste des fichiers marques)
        map("n", "<leader>hh", function()
            harpoon.ui:toggle_quick_menu(harpoon:list())
        end, { desc = "Harpoon: menu" })

        -- Sauter directement aux 4 premiers fichiers
        map("n", "<leader>1", function() harpoon:list():select(1) end,
            { desc = "Harpoon: file 1" })
        map("n", "<leader>2", function() harpoon:list():select(2) end,
            { desc = "Harpoon: file 2" })
        map("n", "<leader>3", function() harpoon:list():select(3) end,
            { desc = "Harpoon: file 3" })
        map("n", "<leader>4", function() harpoon:list():select(4) end,
            { desc = "Harpoon: file 4" })

        -- Navigation precedent / suivant dans la liste
        map("n", "<leader>hp", function()
            harpoon:list():prev()
        end, { desc = "Harpoon: prev file" })
        map("n", "<leader>hn", function()
            harpoon:list():next()
        end, { desc = "Harpoon: next file" })

        -- Dans le menu harpoon :
        --   <CR>    -> ouvrir le fichier
        --   d       -> supprimer de la liste
        --   q / Esc -> fermer
    end,
}
