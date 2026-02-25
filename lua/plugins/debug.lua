-- ~/.config/nvim/lua/plugins/debug.lua
-- :MasonInstall codelldb debugpy java-debug-adapter java-test
-- OCaml : opam install earlybird

return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "rcarriga/nvim-dap-ui",
        "nvim-neotest/nvim-nio",
        "mfussenegger/nvim-dap-python",
        "nvim-telescope/telescope.nvim",
    },
    config = function()
        local dap   = require("dap")
        local dapui = require("dapui")

        -- ---------------------------------------------------------------
        -- SIGNES
        -- ---------------------------------------------------------------
        vim.fn.sign_define("DapBreakpoint",
            { text = "B",  texthl = "DiagnosticError", linehl = "", numhl = "" })
        vim.fn.sign_define("DapBreakpointCondition",
            { text = "BC", texthl = "DiagnosticWarn",  linehl = "", numhl = "" })
        vim.fn.sign_define("DapLogPoint",
            { text = "L",  texthl = "DiagnosticInfo",  linehl = "", numhl = "" })
        vim.fn.sign_define("DapStopped",
            { text = ">>", texthl = "DiagnosticOk", linehl = "DapStoppedLine", numhl = "" })
        vim.fn.sign_define("DapBreakpointRejected",
            { text = "R",  texthl = "DiagnosticError", linehl = "", numhl = "" })

        -- ---------------------------------------------------------------
        -- C / C++ / Rust  ->  codelldb
        -- :MasonInstall codelldb
        -- ---------------------------------------------------------------
        local mason_path = vim.fn.stdpath("data") .. "/mason/packages"
        local codelldb   = mason_path .. "/codelldb/extension/adapter/codelldb"

        dap.adapters.codelldb = {
            type = "server",
            port = "${port}",
            executable = {
                command  = vim.fn.filereadable(codelldb) == 1 and codelldb or "codelldb",
                args     = { "--port", "${port}" },
                detached = false,
            },
        }

        local function get_exe()
            return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/", "file")
        end

        dap.configurations.c = {
            {
                name        = "Launch",
                type        = "codelldb",
                request     = "launch",
                program     = get_exe,
                cwd         = "${workspaceFolder}",
                stopOnEntry = false,
                args        = {},
            },
            {
                name        = "Launch with args",
                type        = "codelldb",
                request     = "launch",
                program     = get_exe,
                cwd         = "${workspaceFolder}",
                stopOnEntry = false,
                args        = function()
                    return vim.split(vim.fn.input("Args: "), " ", { trimempty = true })
                end,
            },
            {
                name    = "Attach to process",
                type    = "codelldb",
                request = "attach",
                pid     = function() return require("dap.utils").pick_process() end,
                cwd     = "${workspaceFolder}",
            },
        }

        dap.configurations.cpp  = dap.configurations.c
        dap.configurations.rust = dap.configurations.c

        -- ---------------------------------------------------------------
        -- PYTHON  ->  debugpy
        -- :MasonInstall debugpy
        -- ---------------------------------------------------------------
        local debugpy = mason_path .. "/debugpy/venv/bin/python"
        if vim.fn.filereadable(debugpy) ~= 1 then
            debugpy = vim.fn.exepath("python3") ~= "" and vim.fn.exepath("python3") or "python3"
            vim.notify("DAP: debugpy Mason absent, python3 systeme utilise", vim.log.levels.WARN)
        end

        require("dap-python").setup(debugpy)

        dap.configurations.python = dap.configurations.python or {}
        table.insert(dap.configurations.python, {
            name       = "Django runserver",
            type       = "python",
            request    = "launch",
            program    = "${workspaceFolder}/manage.py",
            args       = { "runserver", "--noreload" },
            console    = "integratedTerminal",
            justMyCode = false,
        })

        -- ---------------------------------------------------------------
        -- JAVA  ->  attach JVM (launch via ftplugin/java.lua)
        -- :MasonInstall java-debug-adapter java-test
        -- ---------------------------------------------------------------
        dap.adapters.java = function(cb)
            cb({ type = "server", host = "127.0.0.1", port = 5005 })
        end

        dap.configurations.java = {
            {
                name     = "Attach JVM (port 5005)",
                type     = "java",
                request  = "attach",
                hostName = "127.0.0.1",
                port     = 5005,
            },
        }

        -- ---------------------------------------------------------------
        -- OCAML  ->  earlybird
        -- opam install earlybird
        -- ---------------------------------------------------------------
        local earlybird = vim.fn.exepath("ocamlearlybird")

        dap.adapters.ocamlearlybird = {
            type    = "executable",
            command = earlybird ~= "" and earlybird or "ocamldebug",
            args    = earlybird ~= "" and { "debug" } or {},
        }

        if earlybird == "" then
            vim.notify("DAP OCaml: ocamlearlybird absent (opam install earlybird)", vim.log.levels.WARN)
        end

        dap.configurations.ocaml = {
            {
                name    = "OCaml: main.bc",
                type    = "ocamlearlybird",
                request = "launch",
                program = "${workspaceFolder}/_build/default/bin/main.bc",
                cwd     = "${workspaceFolder}",
            },
            {
                name    = "OCaml: test.bc",
                type    = "ocamlearlybird",
                request = "launch",
                program = "${workspaceFolder}/_build/default/test/test.bc",
                cwd     = "${workspaceFolder}",
            },
            {
                name    = "OCaml: custom",
                type    = "ocamlearlybird",
                request = "launch",
                program = function()
                    return vim.fn.input("Bytecode: ", vim.fn.getcwd() .. "/", "file")
                end,
                cwd     = "${workspaceFolder}",
            },
        }

        -- ---------------------------------------------------------------
        -- DAP UI
        -- ---------------------------------------------------------------
        dapui.setup({
            icons = { expanded = "v", collapsed = ">", current_frame = ">>" },
            layouts = {
                {
                    elements = {
                        { id = "scopes",      size = 0.35 },
                        { id = "breakpoints", size = 0.20 },
                        { id = "stacks",      size = 0.25 },
                        { id = "watches",     size = 0.20 },
                    },
                    size     = 42,
                    position = "left",
                },
                {
                    elements = {
                        { id = "repl",    size = 0.5 },
                        { id = "console", size = 0.5 },
                    },
                    size     = 14,
                    position = "bottom",
                },
            },
            controls = {
                enabled = true,
                element = "repl",
                icons   = {
                    pause      = "||",
                    play       = ">",
                    step_into  = "->",
                    step_over  = "=>",
                    step_out   = "<-",
                    step_back  = "<<",
                    run_last   = ">>",
                    terminate  = "X",
                    disconnect = "~",
                },
            },
        })

        dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
        dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
        dap.listeners.before.event_exited["dapui_config"]     = function() dapui.close() end

        -- ---------------------------------------------------------------
        -- KEYMAPS
        -- ---------------------------------------------------------------
        local map = vim.keymap.set

        -- Execution
        map("n", "<leader>dc", dap.continue,      { desc = "DAP: continue / start" })
        map("n", "<leader>di", dap.step_into,     { desc = "DAP: step into" })
        map("n", "<leader>do", dap.step_over,     { desc = "DAP: step over" })
        map("n", "<leader>dO", dap.step_out,      { desc = "DAP: step out" })
        map("n", "<leader>dR", dap.run_to_cursor, { desc = "DAP: run to cursor" })
        map("n", "<leader>dq", dap.terminate,     { desc = "DAP: terminate" })
        map("n", "<leader>dQ", function()
            dap.terminate()
            dapui.close()
        end, { desc = "DAP: terminate + close UI" })

        -- Breakpoints
        map("n", "<leader>db", dap.toggle_breakpoint, { desc = "DAP: toggle breakpoint" })
        map("n", "<leader>dB", function()
            dap.set_breakpoint(vim.fn.input("Condition: "))
        end, { desc = "DAP: conditional breakpoint" })
        map("n", "<leader>dl", function()
            dap.set_breakpoint(nil, nil, vim.fn.input("Log: "))
        end, { desc = "DAP: log point" })
        map("n", "<leader>dC", dap.clear_breakpoints, { desc = "DAP: clear all breakpoints" })

        -- UI
        map("n", "<leader>dt", dapui.toggle,  { desc = "DAP: toggle UI" })
        map("n", "<leader>dr", dap.repl.open, { desc = "DAP: open REPL" })

        -- Hover : appel lazy pour eviter require au chargement
        map("n", "<leader>dh", function()
            require("dap.ui.widgets").hover()
        end, { desc = "DAP: hover variable" })

        map("v", "<leader>dh", function()
            require("dap.ui.widgets").hover()
        end, { desc = "DAP: hover selection" })

        map("n", "<leader>dp", function()
            local w = require("dap.ui.widgets")
            w.centered_float(w.scopes)
        end, { desc = "DAP: preview scopes" })

        -- Diagnostics
        map("n", "<leader>de", function()
            require("telescope.builtin").diagnostics()
        end, { desc = "DAP: telescope diagnostics" })

        -- Python
        map("n", "<leader>dpm", function()
            require("dap-python").test_method()
        end, { desc = "DAP: test method (Python)" })
        map("n", "<leader>dpc", function()
            require("dap-python").test_class()
        end, { desc = "DAP: test class (Python)" })
    end,
}
