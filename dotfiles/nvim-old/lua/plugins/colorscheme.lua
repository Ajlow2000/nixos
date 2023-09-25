local default_colorscheme = "everforest"

if vim.env.profile == "bare" then
    default_colorscheme = "tokyonight"
end

local status_ok, _ = pcall(vim.cmd, "colorscheme " .. default_colorscheme)
if not status_ok then
  return
end
