#!/usr/bin/env -S nvim -l

vim.env.LAZY_STDPATH = ".tests"
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/refs/tags/v11.17.5/bootstrap.lua"))()

-- Setup lazy.nvim
require("lazy.minit").busted({
  spec = {
    "nvim-treesitter/nvim-treesitter",
    commit = "cf12346a3414fa1b06af75c79faebe7f76df080a",
  },
  rocks = {
    enabled = false,
  },
})
