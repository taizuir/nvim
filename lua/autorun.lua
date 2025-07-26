local M = {}

function M.run_program()
	local file = vim.fn.expand("%:p")
	local extension = vim.fn.expand("%:e")
	local filename = vim.fn.expand("%:t:r")

	local commands = {
		py = string.format("python %s", file),
		java = string.format("javac %s && java %s", file, filename),
		c = string.format("gcc %s -o %s.out && ./%s.out", file, filename, filename),
		cpp = string.format("g++ %s -o %s.out && ./%s.out", file, filename, filename),
	}

	local command = commands[extension]

	if command then
		vim.cmd("split | terminal " .. command)
	else
		print("Extension non supportée : " .. extension)
	end
end

return M
