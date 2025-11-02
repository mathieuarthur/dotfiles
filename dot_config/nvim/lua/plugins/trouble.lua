return
{
    "folke/trouble.nvim",
    cmd = "Trouble",
    config = 
      function()
        vim.keymap.set('n', "<leader>xx", ":Trouble diagnostics toggle<cr>", { noremap = true, desc = "Diagnostics (Trouble)" })
      end
}
