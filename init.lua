require("config.lazy")

vim.keymap.set("n", "<leader><leader>", function()
	local file_type = vim.fn.expand("%:e")
	local commands = {
		py = "python",
		js = "node",
		sh = "bash",
		java = function()
			-- Compile and run Java code
			local filename = vim.fn.expand("%:t:r")
			vim.cmd("!javac % && java " .. filename)
		end,
		c = function()
			-- Compile and run C code
			local filename = vim.fn.expand("%:t:r")
			vim.cmd("!gcc % -o " .. filename .. " && ./" .. filename)
		end,
		cpp = function()
			-- Compile and run C++ code
			local filename = vim.fn.expand("%:t:r")
			vim.cmd("!g++ % -o " .. filename .. " && ./" .. filename)
		end,
		ml = "ocaml", -- OCaml interpreter
	}

	local command = commands[file_type]
	if type(command) == "function" then
		command()
	elseif command then
		vim.cmd("terminal " .. command .. " %")
	else
		print("No command defined for file type: " .. file_type)
	end
end)
