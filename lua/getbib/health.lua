local util = require("getbib.util")
local getbib = require("getbib")
local health = {}

-- health check
-- run with :checkhealth getbib
health.check = function()
    vim.health.start("getbib report")

    vim.health.info("Configuration options:")
    vim.health.info(vim.inspect(getbib.config))

    if util.check_executable(getbib.config.cmd) then
        vim.health.ok("BibTeX fetcher executable")
        vim.health.info("Full path to executable: " .. vim.fn.exepath(getbib.config.cmd))
    else
        vim.health.error("Command " .. getbib.config.cmd .. " is not executable")
    end
end

return health
