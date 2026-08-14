return {
	"Vigemus/iron.nvim",
	config = function()
		local iron = require("iron.core")
		local view = require("iron.view")
		local common = require("iron.fts.common")

		iron.setup({
			config = {
				-- keep one REPL per filetype instead of one per buffer
				scratch_repl = true,

				repl_definition = {
					python = {
						command = function()
							-- prefer the project's own .venv if present, fall
							-- back to the system python3 otherwise
							local venv_python = vim.fn.getcwd() .. "/.venv/bin/python3"
							if vim.fn.executable(venv_python) == 1 then
								return { venv_python }
							end
							return { "python3" }
						end,

						format = common.bracketed_paste_python,
						block_dividers = { "# %%", "#%%" },
					},
					ocaml = {
						command = { "utop" },
						-- utop's lambda-term line-editing needs a fully-capable
						-- interactive terminal, which iron's embedded terminal
						-- doesn't always present — "-emacs" mode disables that
						-- and avoids the instant-exit-on-launch issue
					},
				},

				-- open the REPL as a vertical split on the right
				repl_open_cmd = view.split.vertical.botright(60),
			},

			keymaps = {
				send_motion = "<localleader>sc",
				visual_send = "<localleader>sc",
				send_file = "<localleader>sf",
				send_line = "<localleader>sl",
				send_paragraph = "<localleader>sp",
				send_until_cursor = "<localleader>su",
				send_mark = "<localleader>sm",
				mark_motion = "<localleader>mc",
				mark_visual = "<localleader>mc",
				remove_mark = "<localleader>md",
				cr = "<localleader>s<cr>",
				interrupt = "<localleader>s<space>",
				exit = "<localleader>sq",
				clear = "<localleader>cl",
			},

			highlight = { italic = true },
			ignore_blank_lines = true,
		})

		-- global REPL controls (not tied to sending code)
		vim.keymap.set("n", "<leader>rs", "<cmd>IronRepl<cr>", { desc = "[R]epl [S]tart/toggle" })
		vim.keymap.set("n", "<leader>rr", "<cmd>IronRestart<cr>", { desc = "[R]epl [R]estart" })
		vim.keymap.set("n", "<leader>rf", "<cmd>IronFocus<cr>", { desc = "[R]epl [F]ocus" })
		vim.keymap.set("n", "<leader>rh", "<cmd>IronHide<cr>", { desc = "[R]epl [H]ide" })

		-- debug: prints exit code + captures stderr if utop/python3 aren't
		-- found on $PATH, instead of the window just silently closing
		-- scoped to iron's own REPL buffers only (filetype "iron") so it
		-- doesn't misfire on unrelated terminals like the <leader><leader> runner
		vim.api.nvim_create_autocmd("TermClose", {
			pattern = "*",
			callback = function(args)
				local ok, ft = pcall(vim.api.nvim_get_option_value, "filetype", { buf = args.buf })
				if not ok or ft ~= "iron" then
					return
				end
				local exit_code = vim.v.event.status
				if exit_code ~= 0 then
					vim.notify(
						"Iron REPL process exited with code " .. exit_code .. " — check the interpreter is on $PATH",
						vim.log.levels.WARN
					)
				end
			end,
		})
	end,
}
