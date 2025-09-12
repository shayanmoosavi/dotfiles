return {
	{
		"rolv-apneseth/tfm.nvim",
		lazy = false,
		opts = {
			-- Possible choices: "ranger" | "nnn" | "lf" | "vifm" | "yazi" (default)
			file_manager = "yazi",
			enable_cmds = true,
			keybindings = {
				["<ESC>"] = "q",
			},
		},
		keys = {
			{
				"<leader>ee",
				":Tfm<CR>",
				desc = "TFM",
			},
			{
				"<leader>eh",
				":TfmSplit<CR>",
				desc = "TFM - horizontal split",
			},
			{
				"<leader>ev",
				":TfmVsplit<CR>",
				desc = "TFM - vertical split",
			},
			{
				"<leader>et",
				":TfmTabedit<CR>",
				desc = "TFM - new tab",
			},
			{
				"<leader>ec",
				function()
					require("tfm").select_file_manager(vim.fn.input("Change file manager: "))
				end,
				desc = "TFM - change selected file manager",
			},
		},
	},
}
