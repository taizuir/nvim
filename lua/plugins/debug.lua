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
	end,
}
