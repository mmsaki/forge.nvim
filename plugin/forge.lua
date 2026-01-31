if not pcall(require, "forge") then
  return
end

if not package.loaded["forge"]._setup_called then
  require("forge").setup({})
end
