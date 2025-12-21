-- register commands
vim.api.nvim_create_user_command("GetBib", require("getbib").get_bib_command, { nargs = '?' })
-- vim.api.nvim_create_user_command("GetBib",
--     function(args)
--         require("getbib").get_bib_command(args)
--     end,
--     { nargs = '?' }
-- )
