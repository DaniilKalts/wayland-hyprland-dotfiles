return {
  "goolord/alpha-nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },

  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    dashboard.section.header.val = {
      "███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗",
      "████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║",
      "██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║",
      "██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║",
      "██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║",
      "╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝",
    }

    dashboard.section.buttons.val = {
      dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
      dashboard.button("f", "  Find file", ":Telescope find_files<CR>"),
      dashboard.button("r", "  Recent files", ":Telescope oldfiles<CR>"),
      dashboard.button("s", "  Settings", ":e $MYVIMRC<CR>"),
      dashboard.button("q", "󰅖  Quit NVIM", ":qa<CR>"),
    }

    local function calculate_padding()
      local total_lines = vim.o.lines
      local header_lines = #dashboard.section.header.val
      local buttons_lines = #dashboard.section.buttons.val
      local footer_lines = #dashboard.section.footer.val
      local content_lines = header_lines + buttons_lines + footer_lines + 6

      local padding_top = math.floor((total_lines - content_lines) / 2)
      return math.max(padding_top, 0)
    end

    local padding_top = calculate_padding()
    dashboard.config.layout = {
      { type = "padding", val = padding_top },
      dashboard.section.header,
      { type = "padding", val = 2 },
      dashboard.section.buttons,
      { type = "padding", val = 2 },
      dashboard.section.footer,
    }

    dashboard.section.header.opts = {
      position = "center",
      hl = "AlphaHeader",
    }
    dashboard.section.footer.opts = {
      position = "center",
      hl = "AlphaFooter",
    }
    for _, button in ipairs(dashboard.section.buttons.val) do
      button.opts.hl = "AlphaButton"
      button.opts.hl_shortcut = "AlphaButtonShortcut"
    end

    alpha.setup(dashboard.config)

    local function toggle_dashboard()
      if vim.api.nvim_buf_get_name(0) == "" and vim.bo.buftype == "" then
        vim.cmd("Alpha")
      else
        vim.cmd("enew")
      end
    end

    -- Close the buffer; fall back to the dashboard when it was the last one.
    local function close_buffer()
      if #vim.fn.getbufinfo({ buflisted = 1 }) > 1 then
        vim.cmd("bprevious")
        vim.cmd("bdelete #")
      else
        local current = vim.api.nvim_get_current_buf()
        vim.cmd("Alpha")
        vim.cmd("bdelete " .. current)
      end
    end

    vim.keymap.set("n", "<leader>H", toggle_dashboard, { desc = "Toggle dashboard" })
    vim.keymap.set("n", "<leader>w", close_buffer, { desc = "Close buffer" })
  end,
}
