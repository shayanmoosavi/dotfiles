return {
    -- LSP Functionality plugins
    -- ---------------------------------------------------------------------------------

    {
        "williamboman/mason.nvim",
        lazy = false,
        config = function()
            require("mason").setup()
        end,
    },
    {
        "williamboman/mason-lspconfig.nvim",
        lazy = false,
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "clangd",
                    "cmake",
                    "fortls",
                    "kotlin_language_server",
                    "lua_ls",
                    "ruff",
                    -- "sqlls",
                    "texlab",
                },
            })
        end,
    },
    {
        "neovim/nvim-lspconfig",
        lazy = false,
        config = function()
            local capabilities = require("cmp_nvim_lsp").default_capabilities()
            local lspconfig = require("lspconfig")

            lspconfig.clangd.setup({
                capabilities = capabilities,
            })
            lspconfig.cmake.setup({

                capabilities = capabilities,
            })
            lspconfig.fortls.setup({

                capabilities = capabilities,
            })
            lspconfig.kotlin_language_server.setup({

                capabilities = capabilities,
            })
            lspconfig.lua_ls.setup({

                capabilities = capabilities,
            })
            lspconfig.ruff.setup({

                capabilities = capabilities,
            })
            lspconfig.texlab.setup({

                capabilities = capabilities,
            })

            vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
            vim.keymap.set("n", "<leader>lgd", vim.lsp.buf.definition, {desc = "Go to Definition"})
            vim.keymap.set("n", "<leader>lgr", vim.lsp.buf.references, {desc = "Go to References"})
            vim.keymap.set("n", "<leader>lca", vim.lsp.buf.code_action, {desc = "Code Action"})
        end,
    },
    {
        "nvimtools/none-ls.nvim",
        lazy = false,
        config = function()
            local null_ls = require("null-ls")

            null_ls.setup({
                sources = {
                    null_ls.builtins.formatting.stylua,
                    null_ls.builtins.diagnostics.pylint,
                },
            })

            vim.keymap.set("n", "<leader>lf", vim.lsp.buf.format, {desc = "Format File"})
        end,
    },

    -- Treesitter for parsing and syntax-aware tasks
    -- ---------------------------------------------------------------------------------

    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            local config = require("nvim-treesitter.configs")
            config.setup({
                ensure_installed = {
                    "c",
                    "cmake",
                    "cpp",
                    "fortran",
                    "html",
                    "kotlin",
                    "lua",
                    "markdown",
                    "markdown_inline",
                    "python",
                    "sql",
                    "toml",
                    "vim",
                    "vimdoc",
                },
                highlight = { enable = true },
                indent = { enable = true },
            })
        end,
    },

    -- Autocomplete and snippets plugins
    -- ---------------------------------------------------------------------------------

    {
        "hrsh7th/cmp-nvim-lsp",
    },
    {
        "L3MON4D3/LuaSnip",
        dependencies = {
            "saadparwaiz1/cmp_luasnip",
            "rafamadriz/friendly-snippets",
        },
        lazy = true,
    },
    {
    },
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "brenoprata10/nvim-highlight-colors",
            "hrsh7th/cmp-path",
        },
        lazy = true,
        config = function()
            local cmp = require("cmp")
            require("luasnip.loaders.from_vscode").lazy_load()

            cmp.setup({
                snippet = {
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body)
                    end,
                },
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"] = cmp.mapping.abort(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                }, {
                    { name = "buffer" },
                }, {name = "path"},
                { name = 'render-markdown' }),
                formatting = {
                    format = require("nvim-highlight-colors").format,
                },
            })
        end,
    },
}
