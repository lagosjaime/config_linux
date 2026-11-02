return {
  "mikavilpas/yazi.nvim",
  event = "VeryLazy",
  opts = {
    open_for_directories = false,
  },
  keys = {
    {
      "<leader>-",
      function()
        require("yazi").yazi()
      end,
      desc = "Abrir yazi en el directorio actual",
    },
  },
}
