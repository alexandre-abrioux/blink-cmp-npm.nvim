# blink-cmp-npm

A [`blink.cmp`](https://github.com/Saghen/blink.cmp) source that provides
completions for NPM packages and versions in `package.json` files.

This plugin is an adaptation of [`cmp-npm`](https://github.com/David-Kunz/cmp-npm),
modified to work natively with `blink.cmp`.

[![Demo Gif](https://raw.githubusercontent.com/alexandre-abrioux/blink-cmp-npm.nvim/refs/heads/main/demo.gif)](https://asciinema.org/a/718781?t=2)

## Requirements

- [`neovim`](https://github.com/neovim/neovim) > `0.7.0`
- [`blink.cmp`](https://github.com/Saghen/blink.cmp)
- [`npm`](https://github.com/npm/cli)

## Installation

Add the plugin to your packer manager and make sure it is loaded before `blink.cmp`.

### Using [`lazy.nvim`](https://github.com/folke/lazy.nvim)

```lua
{
  "saghen/blink.cmp",
  dependencies = { "alexandre-abrioux/blink-cmp-npm.nvim" },
  opts = {
    sources = {
      default = {
        -- enable "npm" in your sources list
        "npm"
      },
      providers = {
        -- configure the provider
        npm = {
          name = "npm",
          module = "blink-cmp-npm",
          async = true,
          -- optional - make blink-cmp-npm completions top priority (see `:h blink.cmp`)
          score_offset = 100,
          -- optional - blink-cmp-npm config
          ---@module "blink-cmp-npm"
          ---@type blink-cmp-npm.Options
          opts = {
            ignore = {},
            only_semantic_versions = true,
            only_latest_version = false,
          }
        },
      },
    },
  },
},
```

### Options

| Option                   | Type       | Default | Description                                            |
| ------------------------ | ---------- | ------- | ------------------------------------------------------ |
| `ignore`                 | `string[]` | `{}`    | Ignore versions that match any of these strings.       |
| `only_semantic_versions` | `boolean`  | `true`  | Ignore versions that do not match semantic versioning. |
| `only_latest_version`    | `boolean`  | `false` | When suggesting versions, only show the latest.        |

## Usage

Once installed and enabled,
completions will automatically be provided when working with `package.json` files.

## Contributing

Contributions are welcome! Feel free to submit a Pull Request.

## Acknowledgements

Special thanks to:

- [@David-Kunz](https://github.com/David-Kunz/cmp-npm) for his work on [`cmp-npm`](https://github.com/David-Kunz/cmp-npm) 🙏
- [@Saghen](https://github.com/Saghen/blink.cmp) for creating and maintaining [`blink.cmp`](https://github.com/Saghen/blink.cmp) 🚀
