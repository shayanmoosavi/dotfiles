return {
	{
		"zaldih/themery.nvim",
		lazy = false,
		config = function()
			require("themery").setup({
				themes = {
					"nord",
					"catppuccin-frappe",
					"catppuccin-macchiato",
					"catppuccin-mocha",
					"tokyonight-moon",
					"tokyonight-storm",
					"tokyonight-night",
				},
				livePreview = true,
				vim.keymap.set("n", "<leader>t", ":Themery <CR>", { silent = true , desc = "Change Theme"}),
			})
		end,
	},
	{
		"brenoprata10/nvim-highlight-colors",
		config = function()
			require("nvim-highlight-colors").setup({})
		end,
	},
	{
		"shaunsingh/nord.nvim",
		name = "nord",
		priority = 1000,
		config = function()
			vim.g.nord_contrast = true
			vim.cmd.colorscheme("nord")
		end,
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 999,
	},
	{
		"folke/tokyonight.nvim",
		name = "tokyonight",
		lazy = false,
		priority = 998,
		opts = {},
	},
}
