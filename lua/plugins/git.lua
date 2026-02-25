-- ~/.config/nvim/lua/plugins/git.lua
-- Utilitaires git avances :
--   1. kdheepak/lazygit.nvim     -> interface lazygit dans un flottant
--   2. sindrets/diffview.nvim    -> diff et historique de fichiers
--   3. NeogitOrg/neogit          -> interface git a la Magit (Emacs)
--
-- gitsigns est dans extras.lua (hunks, blame, stage)
--
-- Keymaps (prefixe <leader>g* coherent avec gitsigns) :
--   <leader>gg  -> LazyGit
--   <leader>gf  -> DiffView fichier courant
--   <leader>gh  -> Historique du fichier courant
--   <leader>gH  -> Historique du projet
--   <leader>gn  -> Neogit

-- =====================================================
-- 1. LAZYGIT
-- =====================================================
local lazygit = {
    "kdheepak/lazygit.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd  = {
        "LazyGit",
        "LazyGitConfig",
        "LazyGitCurrentFile",
        "LazyGitFilter",
        "LazyGitFilterCurrentFile",
    },
    config = function()
        -- Flottant plein ecran
        vim.g.lazygit_floating_window_winblend = 0
        vim.g.lazygit_floating_window_scaling_factor = 0.95
        vim.g.lazygit_floating_window_border_chars = {
            "+" , "-", "+", "|", "+", "-", "+", "|"
        }
        vim.g.lazygit_use_neovim_remote = 1

        local map = vim.keymap.set
        -- LazyGit sur le repo courant
        map("n", "<leader>gg", "<cmd>LazyGit<CR>",
            { desc = "Git: LazyGit" })
        -- LazyGit filtre sur le fichier courant
        map("n", "<leader>gF", "<cmd>LazyGitCurrentFile<CR>",
            { desc = "Git: LazyGit current file" })
    end,
}

-- =====================================================
-- 2. DIFFVIEW
-- =====================================================
local diffview = {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd  = {
        "DiffviewOpen",
        "DiffviewClose",
        "DiffviewToggleFiles",
        "DiffviewFocusFiles",
        "DiffviewFileHistory",
    },
    config = function()
        local actions = require("diffview.actions")

        require("diffview").setup({
            diff_binaries    = false,
            enhanced_diff_hl = true,
            use_icons        = true,
            show_help_hints  = true,

            -- Disposition des panneaux
            view = {
                -- Diff d'un fichier : cote a cote
                default = {
                    layout = "diff2_horizontal",
                    winbar_info = true,
                },
                -- Diff de merge : 3 panneaux
                merge_tool = {
                    layout = "diff3_horizontal",
                    disable_diagnostics = true,
                    winbar_info = true,
                },
                -- Historique : diff vertical
                file_history = {
                    layout = "diff2_horizontal",
                    winbar_info = true,
                },
            },

            file_panel = {
                listing_style = "tree",
                tree_options  = {
                    flatten_dirs         = true,
                    folder_statuses      = "only_folded",
                },
                win_config = {
                    position = "left",
                    width    = 30,
                },
            },

            file_history_panel = {
                log_options = {
                    git = {
                        single_file = {
                            diff_merges = "combined",
                        },
                        multi_file = {
                            diff_merges = "first-parent",
                        },
                    },
                },
                win_config = {
                    position = "bottom",
                    height   = 16,
                },
            },

            -- Keymaps dans diffview
            keymaps = {
                disable_defaults = false,
                view = {
                    { "n", "<leader>e",  actions.focus_files,    { desc = "Focus file panel" } },
                    { "n", "<leader>b",  actions.toggle_files,   { desc = "Toggle file panel" } },
                    { "n", "g<C-x>",     actions.cycle_layout,   { desc = "Cycle layout" } },
                    { "n", "[x",         actions.prev_conflict,  { desc = "Prev conflict" } },
                    { "n", "]x",         actions.next_conflict,  { desc = "Next conflict" } },
                    -- Choisir le cote en cas de conflit
                    { "n", "<leader>co", actions.conflict_choose("ours"),   { desc = "Choose ours" } },
                    { "n", "<leader>ct", actions.conflict_choose("theirs"), { desc = "Choose theirs" } },
                    { "n", "<leader>cb", actions.conflict_choose("base"),   { desc = "Choose base" } },
                    { "n", "<leader>ca", actions.conflict_choose("all"),    { desc = "Choose all" } },
                    { "n", "dx",         actions.conflict_choose("none"),   { desc = "Delete conflict" } },
                },
                file_panel = {
                    { "n", "j",         actions.next_entry,      { desc = "Next file" } },
                    { "n", "k",         actions.prev_entry,      { desc = "Prev file" } },
                    { "n", "<CR>",      actions.select_entry,    { desc = "Open diff" } },
                    { "n", "s",         actions.toggle_stage_entry, { desc = "Stage/unstage" } },
                    { "n", "S",         actions.stage_all,       { desc = "Stage all" } },
                    { "n", "U",         actions.unstage_all,     { desc = "Unstage all" } },
                    { "n", "X",         actions.restore_entry,   { desc = "Restore file" } },
                    { "n", "R",         actions.refresh_files,   { desc = "Refresh" } },
                    { "n", "q",         "<cmd>DiffviewClose<CR>", { desc = "Close" } },
                },
                file_history_panel = {
                    { "n", "j",   actions.next_entry,      { desc = "Next commit" } },
                    { "n", "k",   actions.prev_entry,      { desc = "Prev commit" } },
                    { "n", "<CR>",actions.select_entry,    { desc = "Open diff" } },
                    { "n", "y",   actions.copy_hash,       { desc = "Copy hash" } },
                    { "n", "q",   "<cmd>DiffviewClose<CR>", { desc = "Close" } },
                },
            },
        })

        local map = vim.keymap.set

        -- Diff de tous les changements non commites
        map("n", "<leader>gd", "<cmd>DiffviewOpen<CR>",
            { desc = "Git: diff working tree" })

        -- Diff entre deux branches / commits
        map("n", "<leader>gD", function()
            local ref = vim.fn.input("Diff against (branch/commit): ")
            if ref ~= "" then
                vim.cmd("DiffviewOpen " .. ref)
            end
        end, { desc = "Git: diff against ref" })

        -- Historique du fichier courant
        map("n", "<leader>gh", "<cmd>DiffviewFileHistory %<CR>",
            { desc = "Git: file history" })

        -- Historique du projet entier
        map("n", "<leader>gH", "<cmd>DiffviewFileHistory<CR>",
            { desc = "Git: project history" })

        -- Fermer diffview
        map("n", "<leader>gq", "<cmd>DiffviewClose<CR>",
            { desc = "Git: close diffview" })
    end,
}

-- =====================================================
-- 3. NEOGIT
-- =====================================================
local neogit = {
    "NeogitOrg/neogit",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "sindrets/diffview.nvim",    -- integration diffview
        "nvim-telescope/telescope.nvim",
    },
    cmd    = "Neogit",
    config = function()
        require("neogit").setup({
            -- Style de la fenetre
            kind               = "tab",      -- tab | split | vsplit | floating
            -- Integration avec diffview pour les diffs
            integrations = {
                diffview   = true,
                telescope  = true,
            },
            -- Confirmation avant certaines actions
            disable_commit_confirmation = false,
            disable_builtin_notifications = false,

            -- Sections affichees au demarrage
            sections = {
                untracked    = { folded = false, hidden = false },
                unstaged     = { folded = false, hidden = false },
                staged       = { folded = false, hidden = false },
                stashes      = { folded = true  },
                unpulled_upstream   = { folded = true  },
                unmerged_upstream   = { folded = false },
                unpulled_pushremote = { folded = true  },
                unmerged_pushremote = { folded = false },
                recent       = { folded = true  },
                rebase       = { folded = true, hidden = false },
            },

            -- Keymaps dans neogit
            mappings = {
                commit_editor = {
                    ["q"] = "Close",
                    ["<c-c><c-c>"] = "Submit",
                    ["<c-c><c-k>"] = "Abort",
                },
                status = {
                    ["q"]  = "Close",
                    ["?"]  = "HelpPopup",
                    ["D"]  = "DiffAtFile",
                    ["s"]  = "Stage",
                    ["S"]  = "StageAll",
                    ["u"]  = "Unstage",
                    ["U"]  = "UnstageAll",
                    ["cc"] = "CommitPopup",
                    ["ca"] = "CommitPopup",
                    ["Fa"] = "FetchPopup",
                    ["Pp"] = "PushPopup",
                    ["Fl"] = "PullPopup",
                    ["b"]  = "BranchPopup",
                    ["X"]  = "DiscardHunk",
                    ["<cr>"] = "Toggle",
                    ["<tab>"] = "Toggle",
                },
            },
        })

        vim.keymap.set("n", "<leader>gn", "<cmd>Neogit<CR>",
            { desc = "Git: Neogit" })
    end,
}

return { lazygit, diffview, neogit }
