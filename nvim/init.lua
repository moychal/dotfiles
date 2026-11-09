-- Leader must be set before plugins load
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- nvim-tree replaces netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Basic options
local o = vim.opt
o.number = true
o.relativenumber = true
o.mouse = "a"
o.clipboard = "unnamedplus"
o.ignorecase = true
o.smartcase = true
o.expandtab = true
o.shiftwidth = 4
o.tabstop = 4
o.signcolumn = "yes"
o.termguicolors = true
o.updatetime = 250
o.splitright = true
o.splitbelow = true
o.undofile = true
o.timeoutlen = 400
o.exrc = true -- load a project's .nvim.lua (nvim asks you to trust it first)

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- Colorscheme
  { "folke/tokyonight.nvim", priority = 1000,
    config = function() vim.cmd.colorscheme("tokyonight-night") end },

  -- File tree sidebar
  { "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = { width = 32 },
        renderer = { group_empty = true },
        filters = { custom = { "^.git$", "^target$" } },
        update_focused_file = { enable = true },
      })
      vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle file tree" })
      vim.keymap.set("n", "<leader>E", "<cmd>NvimTreeFindFile<cr>", { desc = "Reveal file in tree" })
    end },

  -- Fuzzy finding
  { "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = { file_ignore_patterns = { "^.git/", "^target/" } },
        pickers = { find_files = { hidden = true } },
      })
      pcall(telescope.load_extension, "fzf")
      local b = require("telescope.builtin")
      local map = vim.keymap.set
      map("n", ";;", b.find_files, { desc = "Find files" })
      map("n", ";g", b.live_grep, { desc = "Grep in project" })
      map("n", ";b", b.buffers, { desc = "Open buffers" })
      map("n", ";r", b.oldfiles, { desc = "Recent files" })
      map("n", ";s", b.lsp_document_symbols, { desc = "Symbols in file" })
      map("n", ";S", b.lsp_dynamic_workspace_symbols, { desc = "Symbols in project" })
      map("n", ";d", b.diagnostics, { desc = "Diagnostics" })
      map("n", ";h", b.help_tags, { desc = "Help" })
    end },

  -- LSP server installer
  { "mason-org/mason.nvim", opts = {} },
  { "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
    opts = {
      ensure_installed = { "lua_ls" },
      -- No jdtls: too heavy for low-RAM machines. Treesitter handles Java highlighting.
      automatic_enable = { exclude = { "jdtls" } },
    } },

  -- Syntax highlighting / indent via Treesitter (no server process, just a small parser lib)
  { "nvim-treesitter/nvim-treesitter", branch = "master", build = ":TSUpdate",
    main = "nvim-treesitter.configs",
    opts = {
      ensure_installed = { "java", "lua" },
      highlight = { enable = true },
      indent = { enable = true },
    } },

  -- Completion
  { "saghen/blink.cmp", version = "1.*",
    opts = {
      keymap = { preset = "default" }, -- <C-y> accept, <C-n>/<C-p> navigate, <C-space> open
      completion = { documentation = { auto_show = true } },
      signature = { enabled = true },
    } },

  -- Key hint popup
  { "folke/which-key.nvim", event = "VeryLazy", opts = {} },

  -- Clickable tabs for open files (click to switch, middle-click / x to close)
  { "akinsho/bufferline.nvim", version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = { options = {
      diagnostics = "nvim_lsp",
      hover = { enabled = true, delay = 150, reveal = { "close" } },
      offsets = { { filetype = "NvimTree", text = "Files", separator = true } },
    } } },

  -- Status line (mode, git branch, errors/warnings, file position)
  { "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = { options = { globalstatus = true } } },

  -- Git change markers in the gutter
  { "lewis6991/gitsigns.nvim", opts = {} },

  -- Auto-close brackets and quotes
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
})

-- Bufferline hover needs mouse-move events
vim.opt.mousemoveevent = true

-- LSP: global config; mason-lspconfig enables installed servers automatically
vim.lsp.config("lua_ls", {
  settings = { Lua = { diagnostics = { globals = { "vim" } } } },
})

vim.diagnostic.config({ virtual_text = true, severity_sort = true, float = { border = "rounded" } })

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local map = function(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, desc = desc })
    end
    local b = require("telescope.builtin")
    map("gd", b.lsp_definitions, "Go to definition")
    map("gr", b.lsp_references, "References")
    map("gi", b.lsp_implementations, "Implementations")
    map("K", vim.lsp.buf.hover, "Hover docs")
    map("<leader>rn", vim.lsp.buf.rename, "Rename")
    map("<leader>ca", vim.lsp.buf.code_action, "Code action")
    map("<leader>f", function() vim.lsp.buf.format({ async = true }) end, "Format")
    map("<leader>d", vim.diagnostic.open_float, "Line diagnostics")
  end,
})

vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Leave terminal mode" })

-- Handy extras
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>")
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")
