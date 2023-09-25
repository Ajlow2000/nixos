local requirements = {
    "plugins.packer",
    "plugins.whichkey",
    "plugins.colorscheme",
    "plugins.treesitter",
    "plugins.telescope",
    "plugins.comment",
    "plugins.todo",
    "plugins.undotree",
    "plugins.zen",
    "plugins.lspzero",
    "plugins.autopairs",
    "plugins.leap",
    "plugins.harpoon",
    "plugins.dap",
    "plugins.oil",
    "plugins.luasnip"
}

for i = 1, #requirements, 1 do
    local file = requirements[i]

    local ok, err = pcall(require, file)
    if not ok then
    	print(string.format("Error in %s\n\t%s", file, err))
    end
end
