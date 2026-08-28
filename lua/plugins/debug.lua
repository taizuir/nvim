return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"nvim-neotest/nvim-nio",
		"rcarriga/nvim-dap-ui",
		"mfussenegger/nvim-dap-python",
		"mfussenegger/nvim-jdtls",
	},

	config = function()
		local dap = require("dap")

		-- Python debugging (nvim-dap-python was a dependency but setup()
		-- was never called — dap.configurations.python didn't exist before this)
		-- Python debugging (nvim-dap-python was a dependency but setup()
		-- was never called — dap.configurations.python didn't exist before this)
		local function venv_or_system_python()
			local venv_python = vim.fn.getcwd() .. "/.venv/bin/python3"
			if vim.fn.executable(venv_python) == 1 then
				return venv_python
			end
			return "python3"
		end
		require("dap-python").setup(venv_or_system_python())

		-- re-run setup with the right interpreter whenever you open a
		-- python file in a different project (setup() just re-registers
		-- the adapter, safe to call repeatedly)
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "python",
			callback = function()
				require("dap-python").setup(venv_or_system_python())
			end,
		})

		-- Configuration pour le débogage Java
		dap.adapters.java = {
			type = "server",
			host = "127.0.0.1",
			port = 5005,
		}

		dap.configurations.java = {
			{
				type = "java",
				request = "attach",
				name = "Attach to the Java process",
				hostName = "127.0.0.1",
				port = 5005,
			},
		}
		dap.adapters.gdb = {
			type = "executable",
			command = "gdb",
			args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
		}
		dap.configurations.c = {
			{
				name = "Launch",
				type = "gdb",
				request = "launch",
				program = function()
					return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
				end,
				cwd = "${workspaceFolder}",
				stopAtBeginningOfMainSubprogram = false,
			},
			{
				name = "Select and attach to process",
				type = "gdb",
				request = "attach",
				program = function()
					return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
				end,
				pid = function()
					local name = vim.fn.input("Executable name (filter): ")
					return require("dap.utils").pick_process({ filter = name })
				end,
				cwd = "${workspaceFolder}",
			},
			{
				name = "Attach to gdbserver :1234",
				type = "gdb",
				request = "attach",
				target = "localhost:1234",
				program = function()
					return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
				end,
				cwd = "${workspaceFolder}",
			},
		}
		dap.configurations.cpp = dap.configurations.c
		dap.configurations.rust = dap.configurations.c
		dap.adapters.ocamlearlybird = {
			type = "executable",
			command = "ocamlearlybird",
			args = { "debug" },
		}
		dap.configurations.ocaml = {
			{
				name = "OCaml Debug test.bc",
				type = "ocamlearlybird",
				request = "launch",
				program = "${workspaceFolder}/_build/default/test/test.bc",
			},
			{
				name = "OCaml Debug main.bc",
				type = "ocamlearlybird",
				request = "launch",
				program = "${workspaceFolder}/_build/default/bin/main.bc",
			},
		}

		local dapui = require("dapui")

		require("dapui").setup()

		dap.listeners.before.attach.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.launch.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated.dapui_config = function()
			dapui.close()
		end
		dap.listeners.before.event_exited.dapui_config = function()
			dapui.close()
		end

		vim.keymap.set("n", "<Leader>db", dap.toggle_breakpoint, {})
		vim.keymap.set("n", "<Leader>dc", dap.continue, {})
		vim.keymap.set("n", "<Leader>du", dapui.toggle, { desc = "Toggle DAP UI" })
	end,
}
