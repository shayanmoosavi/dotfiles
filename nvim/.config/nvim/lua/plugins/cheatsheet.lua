return {
    "doctorfree/cheatsheet.nvim",
    event = "VeryLazy",

    dependencies = {
        { "nvim-telescope/telescope.nvim" },
        { "nvim-lua/popup.nvim" },
        { "nvim-lua/plenary.nvim" },
    },
    lazy = true,
    config = function()
        local ctactions = require("cheatsheet.telescope.actions")
        require("cheatsheet").setup({

            bundled_cheatsheets = true,
            bundled_plugin_cheatsheets = true,
            include_only_installed_plugins = true,

            -- Key mappings bound inside the telescope window
            telescope_mappings = {
                ["<CR>"] = ctactions.select_or_fill_commandline,
                ["<A-CR>"] = ctactions.select_or_execute,
                ["<C-Y>"] = ctactions.copy_cheat_value,
                ["<C-E>"] = ctactions.edit_user_cheatsheet,
            },
        })
    end,
}
