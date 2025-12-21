local M = {}

-- configuration files
---@class Config
---@field cmd string Name of executable
local config = {
  cmd = "pybibget",
}

-- this holds our configuration
M.config = config

-- check if the configured command is executable
---@return boolean Returns true if configured command is executable
local check_executable = function()
    if vim.fn.executable(M.config.cmd) then
        return true
    else
        return false
    end
end

-- setup variables and check
-- throws an error if something is wrong
M.setup = function()
    if not check_executable() then
        error("Command '" .. M.config.cmd .. "' not found")
    end
end

-- get bibtex from identifier
---@param id string ID of the paper(s) to look up
---@return string[] array of strings
M.get_bibtex = function(id)
    local obj = vim.system({M.config.cmd, '--no-interactive', id}, { text = true }):wait()

    -- TODO: error handling
    return vim.split(obj.stdout, '\n')
end

-- Remove empty leading/trailing empty lines. Note this function changes the variable lines!
---@param lines string[] lines to remove
local remove_trailing_lines = function(lines)
    while lines[1] == "" do
        table.remove(lines,1)
    end
    while lines[#lines] == "" do
        table.remove(lines)
    end
end

-- apply function to table and store result in new table
---@param x table table to apply values to
---@param fun function function to apply, should take one parameter
---@return table Table with resulting values
local map = function(x, fun)
    local ret = {}

    for k, v in pairs(x) do
        ret[k] = fun(v)
    end
    return ret
end

-- display a popup window with lines
---@param lines string[] Lines to show in the float
local open_float = function(lines)
    -- find longest line
    local max_content_width = math.max(unpack(map(lines, string.len)))
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

-- handle the NeoVim command GetBib. 
---@param args table Arguments supplied
M.get_bib_command = function(args)
    -- check if supplied with any argument. If so, insert the resulting bibtex
    if (vim.tbl_count(args.fargs) > 0) then
        local lines = M.get_bibtex(table.remove(args.fargs, 1))
        remove_trailing_lines(lines)
        -- vim.api.nvim_put(lines, "l", true, true)
        open_float(lines)
        return
    end
end

return M
