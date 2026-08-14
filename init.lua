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
		rs = function()
			-- If we're in a cargo project (Cargo.toml exists upward from cwd),
			-- use cargo run so deps/workspace resolve correctly.
			-- Otherwise fall back to rustc for a single standalone file.
			if vim.fn.findfile("Cargo.toml", ".;") ~= "" then
				vim.cmd("terminal cargo run")
			else
				local filename = vim.fn.expand("%:t:r")
				vim.cmd("!rustc % -o " .. filename .. " && ./" .. filename)
			end
		end,
		ml = "ocaml", -- OCaml interpreter
	}

	local command = commands[file_type]
	if type(command) == "function" then
		command()
	elseif command then
		-- split (not full takeover) + pause after exit so fast scripts
		-- (ocaml, sh, etc.) don't flash by before you can read the output
		vim.cmd("botright split | resize 15")
		vim.cmd("terminal " .. command .. ' % ; echo "" ; read -p "[press enter to close] "')
	else
		print("No command defined for file type: " .. file_type)
	end
end)
