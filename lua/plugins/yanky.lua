return {
	"gbprod/yanky.nvim",
	event = { "TextYankPost" },
	opts = {
		highlight = { timer = 150 },
	},
	keys = {
		{ "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank (yanky)" },
		{ "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put after" },
		{ "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put before" },
		{ "gp", "<Plug>(YankyGPutAfter)", mode = { "n", "x" }, desc = "Put after, cursor stays" },
		{ "gP", "<Plug>(YankyGPutBefore)", mode = { "n", "x" }, desc = "Put before, cursor stays" },
		-- cycle through yank history after a put — <C-n>/<C-p> weren't
		-- bound to anything else in this config
		{ "<c-n>", "<Plug>(YankyCycleForward)", desc = "Cycle yank history forward" },
		{ "<c-p>", "<Plug>(YankyCycleBackward)", desc = "Cycle yank history backward" },
	},
}
