-- Bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- Rust support
  { "rust-lang/rust.vim" },

  -- LSP support
  { "neovim/nvim-lspconfig" },

  -- Completion
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "L3MON4D3/LuaSnip" },
  { "saadparwaiz1/cmp_luasnip" },

  -- Telescope (file finder)
  { "nvim-lua/plenary.nvim" },
  { "nvim-telescope/telescope.nvim" },

  -- Auto pairs
  { "windwp/nvim-autopairs", config = true },

  -- Markdown support
  {
    "preservim/vim-markdown",
    ft = "markdown",
    dependencies = {
      "godlygeek/tabular", -- Needed for formatting tables
    },
    config = function()
      vim.g.vim_markdown_folding_disabled = 1 -- Disable folding
      vim.g.vim_markdown_conceal = 0 -- Disable conceal (for better visibility)
    end,
  },

  --## Markdown Preview (requires `markdown-preview.nvim`)
  {
    "iamcco/markdown-preview.nvim",
    ft = "markdown",
    build = function()
      vim.fn["mkdp#util#install"]() -- Auto-install on first run
    end,
    config = function()
      vim.g.mkdp_auto_start = 0 -- Disable auto-start
      vim.g.mkdp_browser = "firefox" -- Set your preferred browser
    end,
  },

  --## Markdown Table Mode (for easy table formatting)
  {
    "dhruvasagar/vim-table-mode",
    ft = "markdown",
    config = function()
      vim.g.table_mode_corner = "|" -- Customize table formatting
    end,
  }
})

-- Basic settings
--vim.opt.number = true
--vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4

-- Rust --
vim.g.rustfmt_autosave = 1

-- Setup rust-analyzer
local lspconfig = require("lspconfig")
lspconfig.rust_analyzer.setup({
  settings = {
    ["rust-analyzer"] = {}
  }
})

-- Setup completion
local cmp = require("cmp")
cmp.setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" }
  })
})

-- Setup autopairs (brackets, quotes etc)
require("nvim-autopairs").setup()

