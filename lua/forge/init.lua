--- forge.nvim - Minimal Neovim plugin to run Foundry commands in a split terminal
-- Supports Forge, Cast, Chisel, and persistent Anvil terminal.
-- Ephemeral buffers (Forge/Cast/Chisel) wipe on close; Anvil is persistent.
local M = {}

--- Plugin configuration table
-- @field allow_standalone boolean Whether to allow running commands in folders without foundry.toml
M.config = {
  allow_standalone = false,
}

--- Stores the buffer number of the persistent Anvil terminal
-- @type integer|nil
M.anvil_buf = nil

--- Find the project root by searching for `foundry.toml` upwards from current directory
-- @return string|nil The path to the directory containing foundry.toml, or nil if not found
local function find_root()
  local found = vim.fs.find("foundry.toml", { upward = true })[1]
  if not found then return nil end
  return vim.fs.dirname(found)
end

--- Open a terminal split for running a command
-- @param args table List of strings: the command and its arguments
-- @param persistent boolean If true, reuse the same buffer (for Anvil)
-- @param name string Name of the buffer to display in the split
local function open_terminal(args, persistent, name)
  local root = find_root()
  if not root then
    if M.config.allow_standalone then
      root = vim.loop.cwd()
    else
      vim.notify("No foundry.toml found", vim.log.levels.WARN)
      return
    end
  end

  local buf
  local height = math.floor(vim.o.lines / 2)

  -- Reuse existing persistent buffer (Anvil) if it exists
  if persistent and M.anvil_buf and vim.api.nvim_buf_is_valid(M.anvil_buf) then
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(win) == M.anvil_buf then
        vim.api.nvim_set_current_win(win)
        return
      end
    end
    -- Buffer exists but not displayed; open top split and attach it
    vim.cmd("topleft " .. height .. "split")
    vim.api.nvim_win_set_buf(0, M.anvil_buf)
    return
  end

  -- Create a new terminal in top-half split
  vim.cmd("topleft " .. height .. "new")
  buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_name(buf, name)

  -- Ephemeral buffers wipe when closed
  if not persistent then
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].swapfile = false
  end

  vim.fn.termopen(args, { cwd = root })

  -- Save buffer number for persistent terminal
  if persistent then
    M.anvil_buf = buf
  end
end

--- Setup the plugin and register user commands
-- @param opts table Optional configuration table (currently supports allow_standalone)
function M.setup(opts)
  M.config = vim.tbl_extend("force", M.config, opts or {})

  --- Helper to create a Neovim user command
  -- @param name string Name of the command (e.g., "Forge")
  -- @param cmd string Command to run in terminal (e.g., "forge")
  -- @param persistent boolean Whether the buffer should be persistent
  local function create_cmd(name, cmd, persistent)
    vim.api.nvim_create_user_command(name, function(options)
      local args = {cmd}
      if #options.fargs > 0 then
        args = vim.tbl_flatten({cmd, unpack(options.fargs)})
      end
      local buf_name = (cmd == "anvil") and "Anvil" or "Terminal Output"
      open_terminal(args, persistent, buf_name)
    end, { nargs = "*", complete = function() return {} end })
  end

  -- Register commands
  create_cmd("Forge", "forge", false)
  create_cmd("Cast", "cast", false)
  create_cmd("Chisel", "chisel", false)
  create_cmd("Anvil", "anvil", true)
end

return M
