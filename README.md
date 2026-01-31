# forge.nvim

A minimal Neovim plugin to run Foundry commands. Supports `Forge`, `Cast`, `Chisel`, and a persistent `Anvil` terminal.

## Features

* Opens Foundry commands in a **top-half split terminal**.
* Ephemeral buffers (`Forge`, `Cast`, `Chisel`) **wipe on close**.
* Persistent buffer (`Anvil`) **reuses the same split**.
* Automatically detects project root via `foundry.toml`.
* Optional `allow_standalone` config to run commands in folders without `foundry.toml`.

## Installation

```lua
-- ~/.config/nvim/lua/forge.lua
return {
  "mmsaki/forge.nvim",
  config = function()
    require("forge").setup({
      allow_standalone = false, -- optional
    })
  end,
}
```

## Commands

| Command             | Description                                | Buffer Persistence                 |
| ------------------- | ------------------------------------------ | ---------------------------------- |
| `:Forge <args...>`  | Run `forge` commands (e.g., `:Forge test`) | Wipe on close                      |
| `:Cast <args...>`   | Run `cast` commands                        | Wipe on close                      |
| `:Chisel <args...>` | Run `chisel` commands                      | Wipe on close                      |
| `:Anvil`            | Start a persistent `anvil` terminal        | Persistent, reused if already open |

## Configuration

Only one optional configuration:

```lua
require("forge").setup({
  allow_standalone = true, -- allows running commands outside of a foundry project
})
```

## Notes

* `Anvil` is persistent; running `:Anvil` again will **reuse the same buffer**.
