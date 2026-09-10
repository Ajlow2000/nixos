vim.filetype.add({
    extension = {
        templ = "templ",
        mdx = "mdx",
    },
})

-- mdx treesitter parser is not yet in nvim-treesitter mainline.
-- Fall back to markdown for syntax highlighting until it ships.
-- Once `mdx` appears via :TSInstall / auto_install, delete this line.
vim.treesitter.language.register("markdown", "mdx")
