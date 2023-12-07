return {
    'BartSte/nvim-project-marks',
    lazy = false,
    config = function()
        require('projectmarks').setup({
            -- If set to a string, the path to the shada file is set to the given value.
            -- If set to a boolean, the global shada file of neovim is used.
            shadafile = '.nvim.shada',

            -- If set to true, the "'" and "`" mappings are are appended by the
            -- `last_position`, and `last_column_position` functions, respectively.
            mappings = true,

            -- Message to be displayed when jumping to a mark.
            message = 'Waiting for mark...'
        })
    end
}
