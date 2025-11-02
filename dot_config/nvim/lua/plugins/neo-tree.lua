return
{
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  lazy = false,
  config = 
      function()
        require("neo-tree").setup({
          filesystem = {
            filtered_items = {
              visible = true,
              hide_dotfiles = false,
              hide_gitignored = false
            }
          }
        })
        vim.keymap.set('n', '<leader>t', ":Neotree filesystem toggle left<CR>", { desc= "Tree file"})
        vim.keymap.set('n', '<leader><Space>', ":Neotree focus <CR>", { noremap = true, silent = true, desc = "Focus NeoTree"})
        vim.keymap.set('n', '<leader>n', "<C-w>l", {silent = true, desc = "Focus current file window"})
        vim.keymap.set("n", "<leader>s", ":Neotree action=set_root", {silent = true, desc = "Set current dir as root"})
      end
}

