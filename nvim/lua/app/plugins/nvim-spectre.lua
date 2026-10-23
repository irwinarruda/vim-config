return {
  "nvim-pack/nvim-spectre",
  keys = {
    {
      "<leader>ss",
      function()
        require("spectre").toggle()
      end,
    },
    {
      "<leader>sf",
      function()
        require("spectre").open_visual({ select_word = true })
      end,
    },
    {
      "<leader>sr",
      function()
        require("spectre.actions").run_replace()
      end,
    },
  },
  opts = {
    replace_engine = {
      ["sed"] = {
        cmd = "sed",
        args = {
          "-i",
          "",
          "-E",
        },
      },
    },
  },
}
