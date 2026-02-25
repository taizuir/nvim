-- ~/.config/nvim/lua/plugins/runner.lua
--
-- Plugins :
--   1. akinsho/toggleterm.nvim  -> terminal split bas + execution rapide par filetype
--   2. stevearc/overseer.nvim   -> task runner (Makefile, dune, Maven, Cargo, pytest...)
--
-- Keymaps (aucun conflit avec lsp.lua / debug.lua / telescope.lua) :
--   <leader>rr  -> executer le fichier courant
--   <leader>rb  -> build seulement (sans run)
--   <leader>rx  -> run avec args custom
--   <leader>rt  -> toggle terminal
--   <leader>or  -> overseer : picker de taches
--   <leader>ot  -> overseer : toggle panneau
--   <C-\>       -> toggle terminal rapide

-- =====================================================
-- 1. TOGGLETERM
-- =====================================================
local toggleterm = {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
        require("toggleterm").setup({
            size            = 15,          -- hauteur du split bas
            open_mapping    = [[<C-\>]],
            direction       = "horizontal", -- toujours split en bas
            shade_terminals = true,
            start_in_insert = true,
            persist_size    = true,
            close_on_exit   = false,
            shell           = vim.o.shell,
        })

        local Terminal = require("toggleterm.terminal").Terminal
        local map      = vim.keymap.set

        -- -------------------------------------------------
        -- Helpers
        -- -------------------------------------------------
        local function term_run(cmd)
            local t = Terminal:new({
                cmd           = cmd,
                direction     = "horizontal",
                close_on_exit = false,
                on_open = function(term)
                    vim.cmd("startinsert!")
                    -- 'q' pour fermer le terminal depuis le mode normal
                    vim.api.nvim_buf_set_keymap(term.bufnr, "t", "q",
                        [[<C-\><C-n><cmd>close<CR>]],
                        { noremap = true, silent = true })
                end,
            })
            t:toggle()
        end

        -- Detecte si on est dans un projet Cargo
        local function in_cargo_project()
            return vim.fn.filereadable(vim.fn.getcwd() .. "/Cargo.toml") == 1
        end

        -- Detecte si on est dans un projet dune (OCaml)
        local function in_dune_project()
            return vim.fn.filereadable(vim.fn.getcwd() .. "/dune-project") == 1
        end

        -- Detecte si on est dans un projet Maven (Java)
        local function in_maven_project()
            return vim.fn.filereadable(vim.fn.getcwd() .. "/pom.xml") == 1
        end

        -- Detecte si on est dans un projet Gradle (Java)
        local function in_gradle_project()
            return vim.fn.filereadable(vim.fn.getcwd() .. "/build.gradle") == 1
                or vim.fn.filereadable(vim.fn.getcwd() .. "/build.gradle.kts") == 1
        end

        -- Python : retourne le bon interpreteur (venv aware)
        local function python_bin()
            if vim.fn.filereadable(vim.fn.getcwd() .. "/.venv/bin/python") == 1 then
                return ".venv/bin/python"
            elseif vim.fn.filereadable(vim.fn.getcwd() .. "/venv/bin/python") == 1 then
                return "venv/bin/python"
            else
                return "python3"
            end
        end

        -- -------------------------------------------------
        -- Runners par filetype
        -- -------------------------------------------------
        local runners = {

            -- C
            c = function(mode)
                local file = vim.fn.expand("%:p")
                if mode == "build" then
                    return "gcc -g -Wall -o /tmp/nvim_out " .. file
                end
                return "gcc -g -Wall -o /tmp/nvim_out " .. file
                    .. " && echo '--- Output ---' && /tmp/nvim_out"
            end,

            -- C++
            cpp = function(mode)
                local file = vim.fn.expand("%:p")
                if mode == "build" then
                    return "g++ -g -Wall -o /tmp/nvim_out " .. file
                end
                return "g++ -g -Wall -o /tmp/nvim_out " .. file
                    .. " && echo '--- Output ---' && /tmp/nvim_out"
            end,

            -- Rust : cargo (projet) ou rustc (fichier seul)
            rust = function(mode)
                if in_cargo_project() then
                    if mode == "build" then return "cargo build" end
                    if mode == "test"  then return "cargo test" end
                    if mode == "check" then return "cargo clippy" end
                    -- run avec selection du binaire si workspace
                    local bins = vim.fn.glob(vim.fn.getcwd() .. "/src/bin/*.rs", 1, 1)
                    if #bins > 1 then
                        local bin = vim.fn.input("Binary to run: ", "")
                        return "cargo run --bin " .. bin
                    end
                    return "cargo run"
                else
                    -- fichier Rust standalone
                    local file = vim.fn.expand("%:p")
                    local out  = "/tmp/" .. vim.fn.expand("%:t:r")
                    return "rustc " .. file .. " -o " .. out
                        .. " && echo '--- Output ---' && " .. out
                end
            end,

            -- OCaml
            ocaml = function(mode)
                local name = vim.fn.expand("%:t:r")
                if in_dune_project() then
                    if mode == "build" then return "dune build" end
                    if mode == "test"  then return "dune test" end
                    return "dune build 2>&1 && dune exec ./" .. name .. ".exe"
                end
                return "ocaml " .. vim.fn.expand("%:p")
            end,

            -- Java
            java = function(mode)
                if in_maven_project() then
                    if mode == "build" then return "mvn compile" end
                    if mode == "test"  then return "mvn test" end
                    return "mvn -q compile exec:java"
                elseif in_gradle_project() then
                    if mode == "build" then return "./gradlew build" end
                    if mode == "test"  then return "./gradlew test" end
                    return "./gradlew run"
                end
                local file = vim.fn.expand("%:p")
                local name = vim.fn.expand("%:t:r")
                local dir  = vim.fn.expand("%:p:h")
                return "javac " .. file .. " && java -cp " .. dir .. " " .. name
            end,

            -- Python
            python = function(mode)
                if mode == "test" then
                    return python_bin() .. " -m pytest -v"
                end
                return python_bin() .. " " .. vim.fn.expand("%:p")
            end,

            -- Autres
            lua        = function() return "lua " .. vim.fn.expand("%:p") end,
            sh         = function() return "bash " .. vim.fn.expand("%:p") end,
            javascript = function() return "node " .. vim.fn.expand("%:p") end,
            typescript = function() return "npx ts-node " .. vim.fn.expand("%:p") end,
        }

        -- -------------------------------------------------
        -- Fonction principale d'execution
        -- -------------------------------------------------
        local function run(mode)
            local ft      = vim.bo.filetype
            local runner  = runners[ft]
            if not runner then
                vim.notify("No runner for filetype: " .. ft, vim.log.levels.WARN)
                return
            end
            term_run(runner(mode or "run"))
        end

        -- -------------------------------------------------
        -- Keymaps
        -- -------------------------------------------------
        map("n", "<leader>rr", function() run("run")   end, { desc = "Run: execute" })
        map("n", "<leader>rb", function() run("build") end, { desc = "Run: build only" })
        map("n", "<leader>rT", function() run("test")  end, { desc = "Run: tests" })
        map("n", "<leader>rk", function() run("check") end, { desc = "Run: check/lint" })

        -- Run avec args custom (demande les args avant de lancer)
        map("n", "<leader>rx", function()
            local ft     = vim.bo.filetype
            local runner = runners[ft]
            if not runner then
                vim.notify("No runner for filetype: " .. ft, vim.log.levels.WARN)
                return
            end
            local base_cmd = runner("run")
            local args     = vim.fn.input("Args: ")
            term_run(base_cmd .. " " .. args)
        end, { desc = "Run: execute with args" })

        -- Toggle terminal
        map("n", "<leader>rt", "<cmd>ToggleTerm<CR>", { desc = "Run: toggle terminal" })

        -- Navigation dans le terminal
        function _G.set_terminal_keymaps()
            local opts = { buffer = 0 }
            map("t", "<Esc>",   [[<C-\><C-n>]],       opts)
            map("t", "<C-h>",   [[<C-\><C-n><C-W>h]], opts)
            map("t", "<C-j>",   [[<C-\><C-n><C-W>j]], opts)
            map("t", "<C-k>",   [[<C-\><C-n><C-W>k]], opts)
            map("t", "<C-l>",   [[<C-\><C-n><C-W>l]], opts)
        end

        vim.api.nvim_create_autocmd("TermOpen", {
            pattern  = "term://*toggleterm#*",
            callback = function() _G.set_terminal_keymaps() end,
        })
    end,
}

-- =====================================================
-- 2. OVERSEER  (task runner avec detection automatique)
-- =====================================================
local overseer = {
    "stevearc/overseer.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
    },
    config = function()
        local overseer = require("overseer")

        overseer.setup({
            -- Utilise toggleterm comme backend d'affichage
            strategy = {
                "toggleterm",
                direction     = "horizontal",
                close_on_exit = false,
            },
            task_list = {
                direction      = "bottom",
                min_height     = 15,
                max_height     = 20,
                default_detail = 1,
            },
            templates = { "builtin" },
        })

        local map = vim.keymap.set
        map("n", "<leader>or", "<cmd>OverseerRun<CR>",         { desc = "Overseer: run task" })
        map("n", "<leader>ot", "<cmd>OverseerToggle<CR>",      { desc = "Overseer: toggle panel" })
        map("n", "<leader>oq", "<cmd>OverseerQuickAction<CR>", { desc = "Overseer: quick action" })
        map("n", "<leader>os", "<cmd>OverseerSaveBundle<CR>",  { desc = "Overseer: save bundle" })
        map("n", "<leader>ol", "<cmd>OverseerLoadBundle<CR>",  { desc = "Overseer: load bundle" })

        -- Integration Telescope
        map("n", "<leader>fo", function()
            require("telescope").extensions.overseer.overseer()
        end, { desc = "Telescope: overseer tasks" })

        -- -------------------------------------------------
        -- Templates custom
        -- -------------------------------------------------

        -- Cargo build
        overseer.register_template({
            name     = "cargo build",
            condition = { callback = function(o)
                return vim.fn.filereadable(o.dir .. "/Cargo.toml") == 1
            end },
            builder = function()
                return {
                    cmd        = { "cargo" },
                    args       = { "build" },
                    name       = "cargo build",
                    components = {
                        { "on_output_quickfix", open = true },
                        "on_exit_set_status",
                        "default",
                    },
                }
            end,
        })

        -- Cargo run
        overseer.register_template({
            name     = "cargo run",
            condition = { callback = function(o)
                return vim.fn.filereadable(o.dir .. "/Cargo.toml") == 1
            end },
            builder = function()
                return {
                    cmd        = { "cargo" },
                    args       = { "run" },
                    name       = "cargo run",
                    components = { "default" },
                }
            end,
        })

        -- Cargo test
        overseer.register_template({
            name     = "cargo test",
            condition = { callback = function(o)
                return vim.fn.filereadable(o.dir .. "/Cargo.toml") == 1
            end },
            builder = function()
                return {
                    cmd        = { "cargo" },
                    args       = { "test" },
                    name       = "cargo test",
                    components = {
                        { "on_output_quickfix", open = true },
                        "on_exit_set_status",
                        "default",
                    },
                }
            end,
        })

        -- Cargo clippy
        overseer.register_template({
            name     = "cargo clippy",
            condition = { callback = function(o)
                return vim.fn.filereadable(o.dir .. "/Cargo.toml") == 1
            end },
            builder = function()
                return {
                    cmd        = { "cargo" },
                    args       = { "clippy" },
                    name       = "cargo clippy",
                    components = {
                        { "on_output_quickfix", open = true },
                        "on_exit_set_status",
                        "default",
                    },
                }
            end,
        })

        -- dune build (OCaml)
        overseer.register_template({
            name     = "dune build",
            condition = { callback = function(o)
                return vim.fn.filereadable(o.dir .. "/dune-project") == 1
            end },
            builder = function()
                return {
                    cmd        = { "dune" },
                    args       = { "build" },
                    name       = "dune build",
                    components = {
                        { "on_output_quickfix", open = true },
                        "on_exit_set_status",
                        "default",
                    },
                }
            end,
        })

        -- dune test (OCaml)
        overseer.register_template({
            name     = "dune test",
            condition = { callback = function(o)
                return vim.fn.filereadable(o.dir .. "/dune-project") == 1
            end },
            builder = function()
                return {
                    cmd        = { "dune" },
                    args       = { "test" },
                    name       = "dune test",
                    components = {
                        { "on_output_quickfix", open = true },
                        "on_exit_set_status",
                        "default",
                    },
                }
            end,
        })

        -- Maven compile + exec (Java)
        overseer.register_template({
            name     = "mvn exec",
            condition = { callback = function(o)
                return vim.fn.filereadable(o.dir .. "/pom.xml") == 1
            end },
            builder = function()
                return {
                    cmd        = { "mvn" },
                    args       = { "-q", "compile", "exec:java" },
                    name       = "mvn exec",
                    components = { "default" },
                }
            end,
        })

        -- Maven test (Java)
        overseer.register_template({
            name     = "mvn test",
            condition = { callback = function(o)
                return vim.fn.filereadable(o.dir .. "/pom.xml") == 1
            end },
            builder = function()
                return {
                    cmd        = { "mvn" },
                    args       = { "test" },
                    name       = "mvn test",
                    components = {
                        { "on_output_quickfix", open = true },
                        "on_exit_set_status",
                        "default",
                    },
                }
            end,
        })

        -- pytest (Python)
        overseer.register_template({
            name     = "pytest",
            condition = { callback = function(o)
                return vim.fn.executable("pytest") == 1
                    or vim.fn.filereadable(o.dir .. "/pyproject.toml") == 1
            end },
            builder = function()
                return {
                    cmd        = { "pytest" },
                    args       = { "-v" },
                    name       = "pytest",
                    components = {
                        { "on_output_quickfix", open = true },
                        "on_exit_set_status",
                        "default",
                    },
                }
            end,
        })
    end,
}

return { toggleterm, overseer }
