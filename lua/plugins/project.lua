local PROJECTS_DIR = vim.fn.expand("~/dev")

local LANGUAGES = {
	{ name = "Rust", key = "rust" },
	{ name = "Python", key = "python" },
	{ name = "OCaml", key = "ocaml" },
	{ name = "C", key = "c" },
	{ name = "C++", key = "cpp" },
	{ name = "Java", key = "java" },
	{ name = "Lua", key = "lua" },
	{ name = "LaTeX", key = "latex" },
	{ name = "Vide (pas de scaffold)", key = "empty" },
}

-- unique table identity so it can never collide with a real project path
local NEW_PROJECT_ENTRY = {}

local function run(cmd, cwd)
	local res = vim.system(cmd, { cwd = cwd, text = true }):wait()
	if res.code ~= 0 then
		vim.notify(
			("`%s` a échoué: %s"):format(table.concat(cmd, " "), res.stderr or ""),
			vim.log.levels.WARN
		)
	end
	return res
end

local function write_file(path, relpath, content)
	local full = path .. "/" .. relpath
	vim.fn.mkdir(vim.fn.fnamemodify(full, ":h"), "p")
	vim.fn.writefile(vim.split(content, "\n"), full)
end

--- Scaffolds a starter project for `lang` at `path`, returns the file to open.
---@return string?
local function scaffold(path, name, lang)
	vim.fn.mkdir(path, "p")

	local main_file
	if lang == "rust" then
		run({ "cargo", "init", "--name", name, "--vcs", "none" }, path)
		write_file(path, ".gitignore", "target/\n")
		main_file = "src/main.rs"
	elseif lang == "ocaml" then
		write_file(path, "dune-project", "(lang dune 3.0)\n")
		write_file(path, "bin/dune", "(executable\n (name main))\n")
		write_file(path, "bin/main.ml", 'let () = print_endline "Hello, ' .. name .. '!"\n')
		write_file(path, ".gitignore", "_build/\n")
		main_file = "bin/main.ml"
	elseif lang == "python" then
		run({ "python3", "-m", "venv", ".venv" }, path)
		write_file(
			path,
			"main.py",
			'def main() -> None:\n    pass\n\n\nif __name__ == "__main__":\n    main()\n'
		)
		write_file(path, ".gitignore", ".venv/\n__pycache__/\n")
		main_file = "main.py"
	elseif lang == "c" then
		write_file(
			path,
			"main.c",
			('#include <stdio.h>\n\nint main(void) {\n    printf("Hello, %s!\\n");\n    return 0;\n}\n'):format(
				name
			)
		)
		write_file(
			path,
			"Makefile",
			"CC = cc\nCFLAGS = -Wall -Wextra -g\n\nmain: main.c\n\t$(CC) $(CFLAGS) -o main main.c\n\nclean:\n\trm -f main\n"
		)
		main_file = "main.c"
	elseif lang == "cpp" then
		write_file(
			path,
			"main.cpp",
			('#include <iostream>\n\nint main() {\n    std::cout << "Hello, %s!\\n";\n    return 0;\n}\n'):format(
				name
			)
		)
		write_file(
			path,
			"Makefile",
			"CXX = c++\nCXXFLAGS = -Wall -Wextra -std=c++20 -g\n\nmain: main.cpp\n\t$(CXX) $(CXXFLAGS) -o main main.cpp\n\nclean:\n\trm -f main\n"
		)
		main_file = "main.cpp"
	elseif lang == "java" then
		write_file(
			path,
			"Main.java",
			('public class Main {\n    public static void main(String[] args) {\n        System.out.println("Hello, %s!");\n    }\n}\n'):format(
				name
			)
		)
		main_file = "Main.java"
	elseif lang == "lua" then
		write_file(path, "init.lua", "-- " .. name .. "\n")
		main_file = "init.lua"
	elseif lang == "latex" then
		write_file(
			path,
			"main.tex",
			("\\documentclass{article}\n\n\\title{%s}\n\n\\begin{document}\n\\maketitle\n\n\\end{document}\n"):format(
				name
			)
		)
		main_file = "main.tex"
	end

	if vim.fn.isdirectory(path .. "/.git") == 0 then
		run({ "git", "init", "-q" }, path)
	end

	return main_file
end

local function new_project()
	vim.ui.input({ prompt = "Nom du projet: " }, function(name)
		if not name or name == "" then
			return
		end
		name = name:gsub("%s+", "-")
		local path = PROJECTS_DIR .. "/" .. name
		if vim.fn.isdirectory(path) == 1 then
			vim.notify("Le dossier " .. path .. " existe déjà", vim.log.levels.ERROR)
			return
		end

		vim.ui.select(LANGUAGES, {
			prompt = "Langage du projet",
			format_item = function(item)
				return item.name
			end,
		}, function(choice)
			if not choice then
				return
			end

			local main_file = scaffold(path, name, choice.key)

			vim.cmd.cd(path)
			pcall(function()
				require("project_nvim.project").set_pwd(path, "manual")
			end)

			if main_file then
				vim.cmd.edit(path .. "/" .. main_file)
			else
				vim.cmd.edit(path)
			end
			vim.notify(("Projet '%s' créé (%s)"):format(name, choice.name), vim.log.levels.INFO)
		end)
	end)
end

--- Custom `Telescope projects` picker: the stock list of recent projects,
--- with a "+ Nouveau projet" entry pinned at the top that runs the
--- language-picking scaffolder above instead of cd-ing into a project.
local function project_switcher()
	local finders = require("telescope.finders")
	local pickers = require("telescope.pickers")
	local telescope_config = require("telescope.config").values
	local actions = require("telescope.actions")
	local state = require("telescope.actions.state")
	local builtin = require("telescope.builtin")
	local entry_display = require("telescope.pickers.entry_display")

	local history = require("project_nvim.utils.history")
	local project = require("project_nvim.project")
	local proj_config = require("project_nvim.config")

	local displayer = entry_display.create({
		separator = " ",
		items = { { width = 30 }, { remaining = true } },
	})

	local function make_display(entry)
		if entry.value == NEW_PROJECT_ENTRY then
			return displayer({ "+ Nouveau projet", { "Créer un projet et choisir son langage", "Comment" } })
		end
		return displayer({ entry.name, { entry.value, "Comment" } })
	end

	local function create_finder()
		local results = history.get_recent_projects()
		for i = 1, math.floor(#results / 2) do
			results[i], results[#results - i + 1] = results[#results - i + 1], results[i]
		end
		table.insert(results, 1, NEW_PROJECT_ENTRY)

		return finders.new_table({
			results = results,
			entry_maker = function(entry)
				if entry == NEW_PROJECT_ENTRY then
					return {
						display = make_display,
						name = "+ Nouveau projet",
						value = NEW_PROJECT_ENTRY,
						ordinal = "+ nouveau projet new create add",
					}
				end
				local name = vim.fn.fnamemodify(entry, ":t")
				return {
					display = make_display,
					name = name,
					value = entry,
					ordinal = name .. " " .. entry,
				}
			end,
		})
	end

	-- Resolves the selection: closes the picker and either kicks off
	-- new_project(), or cd's into the chosen project. Returns
	-- (project_path, cd_successful) like project.nvim's own helper.
	local function change_working_directory(prompt_bufnr, prompt)
		local selected_entry = state.get_selected_entry(prompt_bufnr)
		if selected_entry == nil then
			actions.close(prompt_bufnr)
			return
		end
		if selected_entry.value == NEW_PROJECT_ENTRY then
			actions.close(prompt_bufnr)
			new_project()
			return nil, false
		end
		local project_path = selected_entry.value
		if prompt == true then
			actions._close(prompt_bufnr, true)
		else
			actions.close(prompt_bufnr)
		end
		local cd_successful = project.set_pwd(project_path, "telescope")
		return project_path, cd_successful
	end

	local function find_project_files(prompt_bufnr)
		local project_path, cd_successful = change_working_directory(prompt_bufnr, true)
		if cd_successful then
			builtin.find_files({ cwd = project_path, hidden = proj_config.options.show_hidden, mode = "insert" })
		end
	end

	local function browse_project_files(prompt_bufnr)
		local project_path, cd_successful = change_working_directory(prompt_bufnr, true)
		if cd_successful then
			builtin.file_browser({ cwd = project_path, hidden = proj_config.options.show_hidden })
		end
	end

	local function search_in_project_files(prompt_bufnr)
		local project_path, cd_successful = change_working_directory(prompt_bufnr, true)
		if cd_successful then
			builtin.live_grep({ cwd = project_path, hidden = proj_config.options.show_hidden, mode = "insert" })
		end
	end

	local function recent_project_files(prompt_bufnr)
		local _, cd_successful = change_working_directory(prompt_bufnr, true)
		if cd_successful then
			builtin.oldfiles({ cwd_only = true, hidden = proj_config.options.show_hidden })
		end
	end

	local function delete_project(prompt_bufnr)
		local selected_entry = state.get_selected_entry(prompt_bufnr)
		if selected_entry == nil or selected_entry.value == NEW_PROJECT_ENTRY then
			return
		end
		local choice = vim.fn.confirm("Delete '" .. selected_entry.value .. "' from project list?", "&Yes\n&No", 2)
		if choice == 1 then
			history.delete_project(selected_entry)
			state.get_current_picker(prompt_bufnr):refresh(create_finder(), { reset_prompt = true })
		end
	end

	pickers
		.new({}, {
			prompt_title = "Recent Projects",
			finder = create_finder(),
			previewer = false,
			sorter = telescope_config.generic_sorter({}),
			attach_mappings = function(prompt_bufnr, map)
				map("n", "f", find_project_files)
				map("n", "b", browse_project_files)
				map("n", "d", delete_project)
				map("n", "s", search_in_project_files)
				map("n", "r", recent_project_files)
				map("n", "w", change_working_directory)

				map("i", "<c-f>", find_project_files)
				map("i", "<c-b>", browse_project_files)
				map("i", "<c-d>", delete_project)
				map("i", "<c-s>", search_in_project_files)
				map("i", "<c-r>", recent_project_files)
				map("i", "<c-w>", change_working_directory)

				actions.select_default:replace(function()
					find_project_files(prompt_bufnr)
				end)
				return true
			end,
		})
		:find()
end

return {
	"ahmedkhalf/project.nvim",
	event = "VeryLazy",
	opts = { manual_mode = false, detection_methods = { "lsp", "pattern" } },
	config = function(_, opts)
		require("project_nvim").setup(opts)
		require("telescope").load_extension("projects")
	end,
	keys = {
		{ "<leader>fp", project_switcher, desc = "Changer de projet / Nouveau projet" },
	},
}
