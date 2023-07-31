local dap = require('dap')
local dapui = require('dapui')

-- Keymaps

-- function() require"dap.ui.variables".scopes() end
-- function() require"dap.ui.variables".hover() end
-- function() require"dap.ui.variables".visual_hover() end
-- function() local widgets=require'dap.ui.widgets';widgets.centered_float(widgets.scopes) end
-- function() require"dap".repl.run_last()<CR>')

vim.keymap.set("n", "<F5>", function() require('dap').continue() end,  { desc = "[DAP] - "})
vim.keymap.set("n", "<F10>", function() require('dap').step_over() end,  { desc = "[DAP] - "})
vim.keymap.set("n", "<F11>", function() require('dap').step_into() end,  { desc = "[DAP] - "})
vim.keymap.set("n", "<F12>", function() require('dap').step_out() end,  { desc = "[DAP] - "})

local mappings = {
    d = {
        name = "Debugger",
        u = { function() require('dap').continue() end, "Continue (F5)"},
        i = { function() require('dap').step_over() end, "Step Over (F10)"},
        o = { function() require('dap').step_into() end, "Step Into (F11)" },
        p = { function() require('dap').step_out() end,  "Step Out (F12)"},

        -- s = { function() require('dap').start() end, "Start Debuggger"},
        x = { function() require"dap".close(); require("dapui").close() end, "Stop Debugger"},
        v = { function() require"dapui".toggle() end, "Toggle Debug View"},
        b = { function() require('dap').toggle_breakpoint() end,  "Toggle Breakpoint" },
        B = { function() require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, "Set Conditional Breakpoint" },
        l = { function() require('dap').set_breakpoint(vim.fn.input(nil, nil, 'Log Point Message: ')) end,  "Set Log Point Message" },
        -- r = { function() require('dap').repl.open() end, "Open DAP Repl" },
        h = { ":DapVirtualTextToggle<cr>", "Toggle Virtual Text" },
        t = {
            name = "Telescope",
            c = { function() require"telescope".extensions.dap.commands{} end, "Commands" },
            s = { function() require"telescope".extensions.dap.configurations{} end, "Configurations" },
            b = { function() require"telescope".extensions.dap.list_breakpoints{} end, "List breakpoints" },
            v = { function() require"telescope".extensions.dap.variables{} end, "Variables" },
            f = { function() require"telescope".extensions.dap.frames{} end, "Frames" },
        }
    }
}

wk.register(mappings, { prefix = "<leader><leader>" } )



-- Requirements
--  lldb

-- Adapters
dap.adapters.lldb = {
    type = 'executable',
    command = '/usr/bin/lldb-vscode',
    name = 'lldb'
}

-- Configurations
dap.configurations.rust = {
    {
        name = 'Launch',
        type = 'lldb',
        request = 'launch',
        program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
        args = {},

        -- if you change `runInTerminal` to true, you might need to change the yama/ptrace_scope setting:
        --
        --    echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
        --
        -- Otherwise you might get the following error:
        --
        --    Error on launch: Failed to attach to the target process
        --
        -- But you should be aware of the implications:
        -- https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
        -- runInTerminal = false,
    },
}

dap.configurations.c = dap.configurations.rust
dap.configurations.cpp = dap.configurations.rust

dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
-- dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
-- dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

dapui.setup({
    icons = { expanded = "", collapsed = "", current_frame = "" },
    mappings = {
        -- Use a table to apply multiple mappings
        expand = { "<CR>", "<2-LeftMouse>" },
        open = "o",
        remove = "d",
        edit = "e",
        repl = "r",
        toggle = "t",
    },
    -- Use this to override mappings for specific elements
    element_mappings = {
        -- Example:
        -- stacks = {
        --   open = "<CR>",
        --   expand = "o",
        -- }
    },
    -- Expand lines larger than the window
    -- Requires >= 0.7
    expand_lines = vim.fn.has("nvim-0.7") == 1,
-- Layouts define sections of the screen to place windows.
    -- The position can be "left", "right", "top" or "bottom".
    -- The size specifies the height/width depending on position. It can be an Int
    -- or a Float. Integer specifies height/width directly (i.e. 20 lines/columns) while
    -- Float value specifies percentage (i.e. 0.3 - 30% of available lines/columns)
    -- Elements are the elements shown in the layout (in order).
    -- Layouts are opened in order so that earlier layouts take priority in window sizing.
    layouts = {
        {
            elements = {
                -- Elements can be strings or table with id and size keys.
                { id = "scopes", size = 0.25 },
                "breakpoints",
                "stacks",
                "watches",
            },
            size = 40, -- 40 columns
            position = "left",
        },
        {
            elements = {
                "repl",
                "console",
            },
            size = 0.25, -- 25% of total lines
            position = "bottom",
        },
    },
    controls = {
        -- Requires Neovim nightly (or 0.8 when released)
        enabled = true,
        -- Display controls in this element
        element = "repl",
        icons = {
            pause = "",
            play = "",
            step_into = "",
step_over = "",
            step_out = "",
            step_back = "",
            run_last = "",
            terminate = "",
        },
    },
    floating = {
        max_height = nil, -- These can be integers or a float between 0 and 1.
        max_width = nil, -- Floats will be treated as percentage of your screen.
        border = "single", -- Border style. Can be "single", "double" or "rounded"
        mappings = {
            close = { "q", "<Esc>" },
        },
    },
    windows = { indent = 1 },
    render = {
        max_type_length = nil, -- Can be integer or nil.
        max_value_lines = 100, -- Can be integer or nil.
    }
})

require("nvim-dap-virtual-text").setup {
    enabled = true,                        -- enable this plugin (the default)
    enabled_commands = true,               -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
    highlight_changed_variables = true,    -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
    highlight_new_as_changed = false,      -- highlight new variables in the same way as changed variables (if highlight_changed_variables)
    show_stop_reason = true,               -- show stop reason when stopped for exceptions
    commented = false,                     -- prefix virtual text with comment string
    only_first_definition = true,          -- only show virtual text at first definition (if there are multiple)
    all_references = false,                -- show virtual text on all all references of the variable (not only definitions)
    filter_references_pattern = '<module', -- filter references (not definitions) pattern when all_references is activated (Lua gmatch pattern, default filters out Python modules)
    -- experimental features:
    virt_text_pos = 'eol',                 -- position of virtual text, see `:h nvim_buf_set_extmark()`
    all_frames = false,                    -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
    virt_lines = false,                    -- show virtual lines instead of virtual text (will flicker!)
    virt_text_win_col = nil                -- position the virtual text at a fixed window column (starting from the first text column) ,
                                           -- e.g. 80 to position at column 80, see `:h nvim_buf_set_extmark()`
}
