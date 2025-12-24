-- utility functions
local util = {}

-- check if the configured command is executable
---@return boolean Returns true if configured command is executable
util.check_executable = function(cmd)
    if vim.fn.executable(cmd) then
        return true
    else
        return false
    end
end

-- Remove empty leading/trailing empty lines. Note this function changes the variable lines!
---@param lines string[] lines to remove
util.remove_trailing_lines = function(lines)
    while lines[1] == "" do
        table.remove(lines,1)
    end
    while lines[#lines] == "" do
        table.remove(lines)
    end
end

-- Flatten a table to a single list
---@param tbl table table to flatten
---@param flat? table table to store result in. Can be left empty
---@return table flattened table
util.table_flatten = function(tbl, flat)
    flat = flat or {}

    for _, v in ipairs(tbl) do
        if type(v) == "table" then
            util.table_flatten(v, flat)
        else
            flat[#flat+1] = v
        end
    end
    return flat
end

-- apply function to table and store result in new table
---@param x table table to apply values to
---@param fun function function to apply, should take one parameter
---@return table Table with resulting values
util.map = function(x, fun)
    local ret = {}

    for k, v in pairs(x) do
        ret[k] = fun(v)
    end
    return ret
end


return util
