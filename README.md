# konfig.nvim

Very basic neovim plugin to load configuration files from the current project directory.

## Installation

### [Lazy](https://github.com/folke/lazy.nvim)

```lua
return {
  "dzejkop/konfig.nvim",
  opts = {},
}
```

## Usage

Any .lua and .vim file under `.nvim` will be loaded when a directory is opened.

For safety reasons a prompt will show up to ask if this repository is to be trusted.

After the initial load you can use the `KonfigReload` command to reload the config.
