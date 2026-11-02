return {
  {
    "folke/flash.nvim",
    opts = {
      modes = {
        search = {
          enabled = true,
        },
        char = {
          jump_labels = true,
        },
      },
    },
    keys = {
      {
        "s",
        mode = { "n", "x" },
        function()
          require("flash").jump()
        end,
        desc = "Flash",
      },
      { "s", mode = "o", false }, -- deshabilita Flash en operator-pending
    },
  },
}
