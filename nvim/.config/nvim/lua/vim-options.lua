vim.cmd("set expandtab")
vim.cmd("set tabstop=4")
vim.cmd("set softtabstop=4")
vim.cmd("set shiftwidth=4")
vim.g.mapleader = " "
vim.opt.mouse = "a"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.termguicolors = true

-- Navigate vim panes better
vim.keymap.set('n', '<c-k>', ':wincmd k<CR>', {silent = true})
vim.keymap.set('n', '<c-j>', ':wincmd j<CR>', {silent = true})
vim.keymap.set('n', '<c-h>', ':wincmd h<CR>', {silent = true})
vim.keymap.set('n', '<c-l>', ':wincmd l<CR>', {silent = true})

