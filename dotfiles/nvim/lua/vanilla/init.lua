local requirements = {
    "vanilla.options",
    "vanilla.keymaps",
    "vanilla.autocommands",
}

for i = 1, #requirements, 1 do
    local file = requirements[i]

    local ok, err = pcall(require, file)
    if not ok then
    	print(string.format("Error in %s\n\t%s", file, err))
    end
end
