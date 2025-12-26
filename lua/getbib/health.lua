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

    -- bibtex-tidy support
    if getbib.config.tidy.enabled then
        vim.health.info("bibtex-tidy enabled")
        if util.check_executable(getbib.config.tidy.tidy_cmd) then
            vim.health.ok("bibtex-tidy formatter executable")
            vim.health.info("Full path to executable: " .. vim.fn.exepath(getbib.config.tidy.tidy_cmd))
        else
            vim.health.error("Command " .. getbib.config.tidy.tidy_cmd .. " is not executable")
        end
        vim.health.info("bibtex-tidy options: \n" .. vim.inspect(getbib.config.tidy.tidy_opts))
    else
        vim.health.info("bibtex-tidy not enabled")
    end
end

return health
