local util = require("getbib.util")

local M = {}

-- configuration files
---@class Config
---@field cmd string Name of executable
local default_config = {
  cmd = "pybibget",
}

-- this holds our configuration
M.config = default_config

-- setup variables and check
-- throws an error if something is wrong
M.setup = function(opts)
    opts = opts or {}
    M.config = vim.tbl_deep_extend('force', default_config, opts)

    if not util.check_executable(M.config.cmd) then
        error("Command '" .. M.config.cmd .. "' not found")
    end
end

-- get bibtex from identifier
---@param ids string[] ID of the paper(s) to look up
---@return string[] array of strings
M.get_bibtex = function(ids)
    local obj = vim.system({M.config.cmd, '--no-interactive', unpack(ids)}, { text = true }):wait()

    if obj.code ~= 0 then
        vim.notify("Command exited with non-zero error code.")
        return {}
    end
    return vim.split(obj.stdout, '\n')
end

-- display a popup window with lines
---@param lines string[] Lines to show in the float
local open_float = function(lines)
    -- find longest line
    local max_content_width = math.max(unpack(util.map(lines, string.len)))
    local max_content_height = vim.tbl_count(lines)
    if max_content_height == 0 then
        vim.notify("Empty float", vim.log.levels.INFO)
        return
    end
    local float_width = math.min(max_content_width, math.floor(0.8*vim.o.columns))+1
    local float_height = math.min(max_content_height, math.floor(0.8*vim.o.lines))

    -- create buffer
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, 0, false, lines)
    vim.bo[buf].filetype = 'bib'
    vim.bo[buf].modifiable = false
    vim.bo[buf].swapfile = false
    vim.bo[buf].readonly = true
    vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>close!<CR>", { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "<cmd>close!<CR>", { noremap = true, silent = true })

    -- create window and centre it
    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'win',
        col = math.ceil((vim.o.columns - float_width)/2),
        row = math.ceil((vim.o.lines - float_height)/2),
        width = float_width,
        height = float_height,
        style = "minimal",
        title = " GetBib reference "
    })
    vim.wo[win].wrap = false
end

-- Get start and end of visual selection.
local get_visual_selection_pos = function()
    local start_pos = vim.fn.getpos("v")
    local end_pos = vim.fn.getpos(".")
    local vstart, vend

    -- see if we need to swap
    if (start_pos[2] > end_pos[2]) or ((start_pos[2] == end_pos[2]) and (start_pos[3] > end_pos[3])) then
        vstart = { row = end_pos[2], col = end_pos[3] }
        vend = { row = start_pos[2], col = start_pos[3] }
    else
        vstart = { row = start_pos[2], col = start_pos[3] }
        vend = { row = end_pos[2], col = end_pos[3] }
    end

    -- in visual line mode, "v" and "." marks are not necessarily at the start/end of the line
    if vim.api.nvim_get_mode().mode == "V" then
        vstart.col = 1
        -- find last column in last row
        local line = vim.api.nvim_buf_get_lines(0, vend.row - 1, vend.row, false)[1]
        vend.col = #line
    end

    return vstart, vend
end

-- handle the NeoVim command GetBib. 
---@param args table Arguments supplied
M.get_bib_command = function(args, insert)
    local lines = {}
    local id
    local mode = "insert"
    local vstart, vend

    -- check if supplied with any argument. If so, insert the resulting bibtex
    if (vim.tbl_count(args.fargs) > 0) then
        id = args.fargs
        mode = "insert"
    else
        mode = "replace"

        -- if not coming from visual mode, try to select ID under the cursor
        if not (vim.fn.mode() == 'v' or vim.fn.mode() == 'V') then
            -- try to do a visual select of keyword
            local old_keyword = vim.bo[0].iskeyword
            vim.bo[0].iskeyword = "a-z,A-Z,48-57,:,.,/,-,_"
            vim.cmd("normal! viw")
            vim.bo[0].iskeyword = old_keyword
        end

        vstart, vend = get_visual_selection_pos()

        -- note: indexing is zero-based for nvim_buf_get_text, but 1-based for getpos()
        local ids = vim.api.nvim_buf_get_text(0, vstart.row-1, vstart.col-1, vend.row-1, vend.col, {})
        ids = util.map(ids, function (x)
            return vim.split(x, "%s")
        end)
        id = util.table_flatten(ids)
    end

    -- id should be set now
    lines = M.get_bibtex(id)
    util.remove_trailing_lines(lines)
    if vim.tbl_count(lines) == 0 then
        vim.notify("No bibliographic entries found")
        return
    end

    -- either insert or replace
    if insert then
        if mode == "insert" then
            vim.api.nvim_put(lines, "l", true, true)
        elseif mode == "replace" then
            print(vim.inspect(vstart), vim.inspect(vend))
            vim.api.nvim_buf_set_text(0, vstart.row-1, vstart.col-1, vend.row-1, vend.col, lines)
        end
    else
        open_float(lines)
    end
end

return M
