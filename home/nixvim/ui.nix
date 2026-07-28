{ pkgs, ... }:

{
  imports = [
    ./core.nix
    ./completion.nix
    ./formatting.nix
    ./keymaps.nix
    ./lsp.nix
    ./plugins.nix
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;
    enableMan = false;

    extraConfigLua = ''
      vim.cmd [[ autocmd BufWritePre * :%s/\s\+$//e ]]
      vim.opt.shell = vim.env.SHELL or "sh"

      vim.cmd [[ set wildignore+=*__pycache__,*.pyc,*.o,*.obj,*.svn,*.swp,*.class,*.hg,*.DS_Store,*.min.* ]]

      vim.cmd [[
        autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
      ]]

      require("catppuccin").setup({
        flavour = "mocha",
        background = { light = "latte", dark = "mocha" },
        transparent_background = false,
        show_end_of_buffer = false,
        term_colors = false,
        dim_inactive = { enabled = false, shade = "dark", percentage = 0.15 },
        no_italic = false,
        no_bold = false,
        no_underline = false,
        styles = {
          comments = { "italic" },
          conditionals = { "italic" },
        },
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          treesitter = true,
          notify = false,
          mini = { enabled = true, indentscope_color = "" },
        },
      })
      vim.cmd.colorscheme("catppuccin")
      vim.cmd('highlight Visual cterm=NONE ctermbg=White ctermfg=Black guibg=White guifg=Black')

      require("lualine").setup {
        options = {
          icons_enabled = true,
          theme = "catppuccin",
          component_separators = { left = ")", right = "(" },
          section_separators = { left = "", right = "" },
        },
        sections = {
          lualine_a = { { "mode", icons_enabled = true } },
          lualine_b = { "diagnostics", { "filename", file_status = true, path = 1, icons_enabled = true } },
          lualine_c = { { "branch", icons_enabled = true }, "diff" },
          lualine_x = { "encoding", "fileformat", { "filetype", icons_enabled = true } },
          lualine_y = {
            { function() return require("lsp-progress").progress() end },
            "progress",
          },
          lualine_z = { "location" }
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = { "diff" },
          lualine_c = { "filename" },
          lualine_x = {},
          lualine_y = {},
          lualine_z = {}
        },
      }
      vim.api.nvim_create_augroup("lualine_augroup", { clear = true })
      vim.api.nvim_create_autocmd("User", {
        group = "lualine_augroup",
        pattern = "LspProgressStatusUpdated",
        callback = require("lualine").refresh,
      })

      require("lsp-progress").setup({})

      require("gitsigns").setup({
        signs = {
          add = { text = "│" },
          change = { text = "│" },
          delete = { text = "-" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
          untracked = { text = "┆" },
        },
        signcolumn = true,
        numhl = true,
        linehl = false,
        word_diff = false,
        watch_gitdir = { interval = 1000, follow_files = true },
        attach_to_untracked = true,
        current_line_blame = true,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = "eol",
          delay = 1000,
          ignore_whitespace = false,
        },
        current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
        sign_priority = 6,
        update_debounce = 100,
        status_formatter = nil,
        max_file_length = 40000,
        preview_config = { border = "single", style = "minimal", relative = "cursor", row = 0, col = 1 },
      })

      require("illuminate").configure({
        providers = { "lsp", "treesitter", "regex" },
      })

      require("inc_rename").setup()

      require("tiny-inline-diagnostic").setup({})
      vim.diagnostic.config({ virtual_text = false })
      vim.fn.sign_define("DiagnosticSignError", { text = " ", texthl = "DiagnosticSignError" })
      vim.fn.sign_define("DiagnosticSignWarn",  { text = " ", texthl = "DiagnosticSignWarn" })
      vim.fn.sign_define("DiagnosticSignInfo",  { text = " ", texthl = "DiagnosticSignInfo" })
      vim.fn.sign_define("DiagnosticSignHint",  { text = "󰌵", texthl = "DiagnosticSignHint" })

      require("render-markdown").setup({
        latex = { enabled = false },
      })

      require("todo-comments").setup({
        signs = true,
        sign_priority = 8,
        keywords = {
          FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
          TODO = { icon = " ", color = "info" },
          HACK = { icon = " ", color = "warning" },
          WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
          PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
          NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
          TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
        },
        highlight = {
          multiline = true,
          multiline_pattern = "^.",
          multiline_context = 10,
          before = "",
          keyword = "wide",
          after = "fg",
          pattern = [[.*<(KEYWORDS)\s*:]],
          comments_only = true,
          max_line_len = 400,
          exclude = {},
        },
        colors = {
          error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
          warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
          info = { "DiagnosticInfo", "#2563EB" },
          hint = { "DiagnosticHint", "#10B981" },
          default = { "Identifier", "#7C3AED" },
          test = { "Identifier", "#FF00FF" }
        },
        search = {
          command = "rg",
          args = { "--color=never", "--no-heading", "--with-filename", "--line-number", "--column" },
          pattern = [[\b(KEYWORDS):]],
        },
      })

      local lga_actions = require("telescope-live-grep-args.actions")
      require("telescope").setup({
        defaults = {
          layout_config = { width = 0.99, height = 0.99, prompt_position = "top" },
          file_ignore_patterns = { "node_modules", ".mypy_cache", ".idea" },
          sorting_strategy = "ascending",
          prompt_position = "top",
          prompt_prefix = "  ",
          selection_caret = " ",
          mappings = {
            i = {
              ["<C-d>"] = require("telescope.actions").preview_scrolling_down,
              ["<C-u>"] = require("telescope.actions").preview_scrolling_up,
            },
            n = {
              ["<C-d>"] = require("telescope.actions").preview_scrolling_down,
              ["<C-u>"] = require("telescope.actions").preview_scrolling_up,
            },
          },
        },
        extensions = {
          live_grep_args = {
            auto_quoting = true,
            mappings = {
              i = {
                ["<C-k>"] = lga_actions.quote_prompt(),
                ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
                ["<C-space>"] = lga_actions.to_fuzzy_refine,
              },
            },
          },
        },
      })
      require("telescope").load_extension("live_grep_args")

      local wilder = require("wilder")
      wilder.setup({
        modes = { ":", "/", "?" },
        next_key = "<TAB>",
      })
      wilder.set_option("renderer", wilder.popupmenu_renderer(
        wilder.popupmenu_palette_theme({
          border = "rounded",
          max_height = "75%",
          min_height = 0,
          prompt_position = "top",
          reverse = 0,
        })
      ))

      require("hover").setup {
        init = function() require("hover.providers.lsp") end,
        preview_opts = { border = "single" },
        preview_window = false,
        title = true,
        mouse_providers = { "LSP" },
        mouse_delay = 10000000000000,
      }
      vim.keymap.set("n", "K", require("hover").hover, { desc = "hover.nvim" })
      vim.keymap.set("n", "gK", require("hover").hover_select, { desc = "hover.nvim (select)" })
      vim.keymap.set("n", "<MouseMove>", require("hover").hover_mouse, { desc = "hover.nvim (mouse)" })
      vim.o.mousemoveevent = true

      require("smart-paste").setup()

      require("mini.icons").setup()
      MiniIcons.mock_nvim_web_devicons()

      require("transparent").setup({
        groups = {
          "Normal","NormalNC","Comment","Constant","Special","Identifier",
          "Statement","PreProc","Type","Underlined","Todo","String","Function",
          "Conditional","Repeat","Operator","Structure","LineNr","NonText",
          "SignColumn","CursorLine","CursorLineNr","StatusLine","StatusLineNC",
          "EndOfBuffer",
        },
        extra_groups = {},
        exclude_groups = {},
      })

      require("barbar").setup()
      vim.api.nvim_set_hl(0, "BufferCurrent", { fg = "#696969", bg = "#C0C0C0" })
      vim.api.nvim_set_hl(0, "BufferVisible", { fg = "#CCCCCC", bg = "#222222" })
      vim.api.nvim_set_hl(0, "BufferInactive", { fg = "#888888", bg = "#1A1A1A" })

      require("snacks").setup({
        picker = { layout = { circle = true }, enabled = true, db = { sqlite3_path = "${pkgs.sqlite.out}/lib/libsqlite3.so" } },
        bigfile = { enabled = true },
        indent = { enabled = true, hl = "NonText", priority = 1, scope = { enabled = false } },
        explorer = { enabled = true, notify = true, layout = { fullscreen = false } },
        lazygit = { enabled = true },
        input = { enabled = true },
        notifier = { enabled = true, timeout = 3000 },
        quickfile = { enabled = true },
        scope = { enabled = true },
        scroll = { enabled = true },
        statuscolumn = { enabled = true },
        words = { enabled = true },
      })
      vim.keymap.set("n", "<leader><space>", function() Snacks.picker.smart() end, { desc = "Smart Find Files" })
      vim.keymap.set("n", "<leader>/", function() Snacks.picker.grep() end, { desc = "Grep" })
      vim.keymap.set("n", "<leader>n", function() Snacks.picker.notifications() end, { desc = "Notification History" })
      vim.keymap.set("n", "<BS>", function() Snacks.explorer() end, { desc = "File Explorer" })
      vim.keymap.set("n", "<leader><BS>", function() Snacks.explorer.reveal() end, { desc = "File Explorer" })
      vim.keymap.set("n", "<leader>lg", function() Snacks.lazygit() end, { desc = "Projects" })
      vim.keymap.set("n", "<leader>fp", function() Snacks.picker.projects() end, { desc = "Projects" })
      vim.keymap.set("n", "<leader>fr", function() Snacks.picker.recent() end, { desc = "Recent" })
      vim.keymap.set("n", "<C-e>", function() Snacks.picker.recent() end, { desc = "Recent" })
      vim.keymap.set("n", "<C-y>", function() Snacks.picker.lsp_symbols() end, { desc = "LSP Symbols" })
      vim.keymap.set("n", "<C-d>", function() Snacks.picker.diagnostics_buffer() end, { desc = "LSP Symbols" })
      vim.keymap.set("n", "<C-t>", function() Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } }) end, { desc = "Todo/Fix/Fixme" })
      vim.keymap.set("n", "<leader>gb", function() Snacks.picker.git_branches() end, { desc = "Git Branches" })
      vim.keymap.set("n", "<leader>gll", function() Snacks.picker.git_log() end, { desc = "Git Log" })
      vim.keymap.set("n", "<leader>gL", function() Snacks.picker.git_log_line() end, { desc = "Git Log Line" })
      vim.keymap.set("n", "<leader>gs", function() Snacks.picker.git_status() end, { desc = "Git Status" })
      vim.keymap.set("n", "<C-g>", function() Snacks.picker.git_status() end, { desc = "Git Status" })
      vim.keymap.set("n", "<leader>gd", function() Snacks.picker.git_diff() end, { desc = "Git Diff (Hunks)" })
      vim.keymap.set("n", "<leader>gf", function() Snacks.picker.git_log_file() end, { desc = "Git Log File" })
      vim.keymap.set("n", "<leader>s/", function() Snacks.picker.search_history() end, { desc = "Search History" })
      vim.keymap.set("n", "<leader>sa", function() Snacks.picker.autocmds() end, { desc = "Autocmds" })
      vim.keymap.set("n", "<leader>sb", function() Snacks.picker.lines() end, { desc = "Buffer Lines" })
      vim.keymap.set("n", "<leader>sc", function() Snacks.picker.command_history() end, { desc = "Command History" })
      vim.keymap.set("n", "<leader>sC", function() Snacks.picker.commands() end, { desc = "Commands" })
      vim.keymap.set("n", "<leader>sd", function() Snacks.picker.diagnostics() end, { desc = "Diagnostics" })
      vim.keymap.set("n", "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, { desc = "Buffer Diagnostics" })
      vim.keymap.set("n", "<leader>sh", function() Snacks.picker.help() end, { desc = "Help Pages" })
      vim.keymap.set("n", "<leader>si", function() Snacks.picker.icons() end, { desc = "Icons" })
      vim.keymap.set("n", "<leader>sk", function() Snacks.picker.keymaps() end, { desc = "Keymaps" })
      vim.keymap.set("n", "<leader>sM", function() Snacks.picker.man() end, { desc = "Man Pages" })
      vim.keymap.set("n", "<leader>su", function() Snacks.picker.undo() end, { desc = "Undo History" })
      vim.keymap.set("n", "gd", function() Snacks.picker.lsp_definitions() end, { desc = "Goto Definition" })
      vim.keymap.set("n", "gD", function() Snacks.picker.lsp_declarations() end, { desc = "Goto Declaration" })
      vim.keymap.set("n", "gr", function() Snacks.picker.lsp_references() end, { desc = "References", nowait = true })
      vim.keymap.set("n", "gI", function() Snacks.picker.lsp_implementations() end, { desc = "Goto Implementation" })
      vim.keymap.set("n", "gy", function() Snacks.picker.lsp_type_definitions() end, { desc = "Goto Type Definition" })
      vim.keymap.set("n", "<leader>cR", function() Snacks.rename.rename_file() end, { desc = "Rename File" })
      vim.keymap.set({ "n", "x" }, "<leader>gB", function() Snacks.gitbrowse() end, { desc = "Git Browse" })

      Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
      Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
      Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
      Snacks.toggle.diagnostics():map("<leader>ud")
      Snacks.toggle.line_number():map("<leader>ul")
      Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map("<leader>uc")
      Snacks.toggle.treesitter():map("<leader>uT")
      Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
      Snacks.toggle.inlay_hints():map("<leader>uh")
      Snacks.toggle.indent():map("<leader>ug")
      Snacks.toggle.dim():map("<leader>uD")

      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_save_location = "~/.config/nvim/db_ui"

      vim.cmd [[
        let g:bookmark_no_default_key_mappings = 1
        function! BookmarkMapKeys()
            nmap mm :BookmarkToggle<CR>
            nmap mi :BookmarkAnnotate<CR>
            nmap mn :BookmarkNext<CR>
            nmap mp :BookmarkPrev<CR>
            nmap ma :BookmarkShowAll<CR>
            nmap mc :BookmarkClear<CR>
            nmap mx :BookmarkClearAll<CR>
            nmap mkk :BookmarkMoveUp
            nmap mjj :BookmarkMoveDown
        endfunction
        function! BookmarkUnmapKeys()
            unmap mm
            unmap mi
            unmap mn
            unmap mp
            unmap ma
            unmap mc
            unmap mx
            unmap mkk
            unmap mjj
        endfunction
        autocmd BufEnter * :call BookmarkMapKeys()
        autocmd BufEnter NERD_tree_* :call BookmarkUnmapKeys()
      ]]

      local function open_help_on_right()
        if vim.bo.filetype == "help" then
          vim.cmd("wincmd L")
        end
      end
      vim.api.nvim_create_augroup("HelpOnRight", { clear = true })
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "*.txt",
        callback = open_help_on_right,
        group = "HelpOnRight",
      })

      vim.api.nvim_create_autocmd("TextYankPost", {
        desc = "Highlight when yanking text",
        group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
        callback = function()
          vim.highlight.on_yank()
        end,
      })

      vim.opt.shortmess:append("I")

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "markdown", "markdown_inline" },
        callback = function()
          vim.treesitter.start(0, "markdown")
        end,
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "snacks_picker_list",
        callback = function(ev)
          vim.schedule(function()
            pcall(vim.keymap.del, "n", "<BS>", { buffer = ev.buf })
            vim.keymap.set("n", "<BS>", function()
              Snacks.explorer()
            end, { buffer = ev.buf, silent = true, nowait = true })
          end)
        end,
      })

    '';
  };
}
