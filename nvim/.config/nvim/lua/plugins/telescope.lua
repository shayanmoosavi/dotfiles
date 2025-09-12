return {
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		config = function()
			local builtin = require("telescope.builtin")

			vim.keymap.set("n", "<leader>ff", builtin.find_files, {desc = "Telescope Find Files"})
			vim.keymap.set("n", "<leader>fg", builtin.live_grep, {desc = "Live grep"})
			vim.keymap.set("n", "<leader>fr", builtin.oldfiles, {desc = "Recent Files"})
            vim.keymap.set("n", "<leader>E", builtin.diagnostics, {desc = "Error Diagnostics"})
		end,
	},
	{
		"nvim-telescope/telescope-ui-select.nvim",
		config = function()
			require("telescope").setup({
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown({}),
					},
				},
			})
			require("telescope").load_extension("ui-select")
		end,
	},
}
