# dotfiles

## nvim

Neovim (0.11+) config using lazy.nvim. Lightweight on purpose: Treesitter for highlighting, no Java language server.

Install by symlinking:

```sh
ln -s "$PWD/nvim" ~/.config/nvim
```

Plugins install on first launch. Treesitter parsers need a C compiler (`gcc`).

Projects can add their own settings in a `.nvim.lua` at the project root (`exrc` is on; nvim asks you to `:trust` it first).
