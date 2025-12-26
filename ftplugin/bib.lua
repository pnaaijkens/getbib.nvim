-- define visual mapping for bibtex files
vim.api.nvim_buf_set_keymap(0, 'v', '<leader>gb', '<cmd>GetBib<cr>', { desc = 'Fetch and insert BibTeX for selected ids' })
