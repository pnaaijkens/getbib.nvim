-- register commands
vim.api.nvim_create_user_command("GetBib",
    function(args)
        require("getbib").get_bib_command(args, true)
    end,
    { nargs = '*', range = true }
)
vim.api.nvim_create_user_command("GetBibPopup",
    function(args)
        require("getbib").get_bib_command(args, false)
    end,
    { nargs = '*', range = true }
)
-- and keymap in normal mode
vim.api.nvim_set_keymap('n', '<leader>gb', '<Cmd>GetBibPopup<CR>', { desc = 'Fetch BibTeX for id under cursor' })
