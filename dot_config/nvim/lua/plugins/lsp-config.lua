return
{
  {  
    "williamboman/mason.nvim",
      config = 
        function()
          require("mason").setup()
        end
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "neovim/nvim-lspconfig" },
      config = 
        function()
          require("mason-lspconfig").setup({
            automatic_enable = true,
            ensure_installed = { "lua_ls", "pyright", "ts_ls", "svelte", "rust_analyzer" }
          })
          vim.keymap.set('n', "K", vim.lsp.buf.hover, {})
        end
  }
}
