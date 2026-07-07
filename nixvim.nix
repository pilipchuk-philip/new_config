{ pkgs, ... }:

let
  formatOnSave = pkgs.vimUtils.buildVimPlugin {
    pname = "format-on-save.nvim";
    version = "local";
    src = ./vendor/format-on-save.nvim;
  };
  vimPluginRuscmd = pkgs.vimUtils.buildVimPlugin {
    pname = "vim-plugin-ruscmd";
    version = "local";
    src = ./vendor/vim-plugin-ruscmd;
  };
  smartPaste = pkgs.vimUtils.buildVimPlugin {
    pname = "smart-paste.nvim";
    version = "2026-02-17";
    src = pkgs.fetchFromGitHub {
      owner = "nemanjamalesija";
      repo = "smart-paste.nvim";
      rev = "9ea6755e73bcee9bbcef008ec2dd1278edd69228";
      sha256 = "1hs7hhvm0v2idh5gazg5jy2qymjz4jpaba8rlh6s5z4idacpi4s7";
    };
  };
  treesitterWithParsers = pkgs.vimPlugins.nvim-treesitter.withPlugins (p: [
    p.c
    p.css
    p.diff
    p.html
    p.javascript
    p.json
    p.lua
    p.markdown
    p.markdown_inline
    p.python
    p.query
    p.regex
    p.scss
    p.svelte
    p.typescript
    p.tsx
    p.vim
    p.vimdoc
    p.yaml
    p.latex
    p.vue
    p.typst
  ]);
in
{
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;

    extraPlugins = with pkgs.vimPlugins; [
      actions-preview-nvim
      barbar-nvim
      catppuccin-nvim
      cmp-buffer
      cmp-cmdline
      cmp-nvim-lsp
      cmp-path
      cmp-snippy
      cmp-under-comparator
      copilot-cmp
      copilot-lua
      kommentary
      nvim-snippy
      formatOnSave
      gitsigns-nvim
      hover-nvim
      inc-rename-nvim
      lualine-nvim
      lspkind-nvim
      lsp-progress-nvim
      mini-icons
      mini-nvim
      nvim-autopairs
      nvim-cmp
      nvim-lint
      nvim-lspconfig
      treesitterWithParsers
      nvim-web-devicons
      oil-nvim
      plenary-nvim
      render-markdown-nvim
      snacks-nvim
      sqlite-lua
      telescope-fzf-native-nvim
      telescope-live-grep-args-nvim
      telescope-nvim
      tiny-inline-diagnostic-nvim
      todo-comments-nvim
      transparent-nvim
      vim-bookmarks
      which-key-nvim
      vim-dadbod
      vim-dadbod-completion
      vim-dadbod-ui
      vim-fugitive
      vim-illuminate
      vimPluginRuscmd
      vim-sleuth
      vim-tmux-navigator
      wilder-nvim
      dropbar-nvim
      smartPaste
    ];

    extraFiles = {
      "lua/custom/bookmarks-picker.lua".text =
        builtins.readFile ./vendor/bookmarks-picker.lua;
      "lua/custom/github-helper.lua".text =
        builtins.readFile ./vendor/github-helper.lua;
    };

    extraConfigLua = ''
      vim.g.mapleader = " "
      vim.g.maplocalleader = " "

      vim.o.hlsearch = false
      vim.wo.number = true
      vim.o.mouse = "a"

      vim.o.tabstop = 4
      vim.o.expandtab = true
      vim.o.softtabstop = 4
      vim.o.shiftwidth = 4

      vim.o.breakindent = true
      vim.opt.splitright = true
      vim.opt.splitbelow = true
      vim.opt.title = true

      vim.o.undofile = true

      vim.o.ignorecase = true
      vim.o.smartcase = true

      vim.wo.signcolumn = "yes"
      vim.opt.lazyredraw = true
      vim.opt.showcmd = true
      vim.opt.cursorline = true
      vim.opt.wrap = false
      vim.opt.showmatch = true
      vim.opt.showmode = true
      vim.opt.hlsearch = false
      vim.opt.incsearch = true
      vim.opt.virtualedit = "all"
      vim.opt.fileformats = "unix,dos,mac"

      vim.opt.backup = false
      vim.opt.swapfile = false
      vim.opt.undofile = true

      vim.cmd [[ autocmd BufWritePre * :%s/\s\+$//e ]]
      vim.opt.shell = vim.env.SHELL or "sh"

      vim.opt.relativenumber = true
      vim.opt.smartindent = true
      vim.opt.scrolloff = 8

      vim.opt.encoding = "utf-8"
      vim.scriptencoding = "utf-8"
      vim.opt.fileformat = "unix"

      vim.o.completeopt = "menuone,noselect"
      vim.o.termguicolors = true

      vim.g.translate_source = "ru"
      vim.g.translate_target = "en"

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

      require("nvim-autopairs").setup({
        disable_filetype = { "TelescopePrompt", "spectre_panel" },
      })

      require("snippy").setup({})

      local cmp = require("cmp")
      local lspkind = require("lspkind")
      lspkind.init({ symbol_map = { Copilot = "" } })

      cmp.setup({
        snippet = {
          expand = function(args)
            require("snippy").expand_snippet(args.body)
          end
        },
        window = {
          completion = { border = "rounded", scrollbar = true },
          documentation = { border = "rounded", scrollbar = "║" },
        },
        preselect = cmp.PreselectMode.None,
        formatting = {
          fields = { cmp.ItemField.Kind, cmp.ItemField.Abbr, cmp.ItemField.Menu },
          expandable_indicator = true,
          format = lspkind.cmp_format({
            mode = "symbol_text",
            maxwidth = 50,
            ellipsis_char = "...",
          })
        },
        mapping = {
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<Down>"] = cmp.mapping(cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }), { "i" }),
          ["<Up>"] = cmp.mapping(cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }), { "i" }),
          ["<C-c>"] = cmp.mapping.close(),
          ["<CR>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              local entry = cmp.get_selected_entry()
              if not entry then
                cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
              end
              cmp.confirm()
            else
              fallback()
            end
          end, { "i", "s", "c" }),
          ["<C-d>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
        },
        sources = {
          { name = "nvim_lsp" },
          { name = "copilot" },
          { name = "nvim_lua" },
          { name = "path" },
          { name = "buffer" },
          { name = "snippy" },
        },
      })

      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

      require("copilot").setup({
        suggestion = { enabled = false },
        panel = { enabled = false },
      })
      require("copilot_cmp").setup()
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

      local format_on_save = require("format-on-save")
      local formatters = require("format-on-save.formatters")
      local prettier = formatters.shell({ cmd = { "prettier", "--stdin-filepath", "%" } })
      local env = os.getenv("MY_ENV")
      local python_formatters

      if env == "WORK" then
        python_formatters = {
          formatters.remove_trailing_whitespace,
          formatters.shell({ cmd = { "ruff", "format", "--config", "/home/ppy/work/unixy/python/pyproject.toml", "-" } }),
        }
      else
        python_formatters = {
          formatters.remove_trailing_whitespace,
          formatters.shell({ cmd = { "ruff", "format", "-" } }),
        }
      end

      format_on_save.setup({
        exclude_path_patterns = { "/node_modules/", ".local/share/nvim/lazy" },
        formatter_by_ft = {
          css = formatters.lsp,
          html = formatters.lsp,
          java = formatters.lsp,
          json = formatters.lsp,
          lua = formatters.lsp,
          markdown = prettier,
          openscad = formatters.lsp,
          rust = formatters.lsp,
          scad = formatters.lsp,
          scss = formatters.lsp,
          sh = formatters.shfmt,
          terraform = formatters.lsp,
          typescript = prettier,
          typescriptreact = prettier,
          yaml = formatters.lsp,
          javascript = formatters.lsp,
          sql = {},
          text = formatters.remove_trailing_whitespace,
          python = python_formatters,
          go = {
            formatters.shell({
              cmd = { "goimports-reviser", "-rm-unused", "-set-alias", "-format", "%" },
              tempfile = function()
                return vim.fn.expand("%") .. ".formatter-temp"
              end
            }),
            formatters.shell({ cmd = { "gofmt" } }),
          },
        },
        fallback_formatter = { formatters.remove_trailing_whitespace },
        run_with_sh = false,
      })

      require("lint").linters_by_ft = {
        markdown = { "vale" },
        python = { "mypy", "ruff" },
      }
      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        callback = function()
          require("lint").try_lint()
        end,
      })

      require("oil").setup({
        default_file_explorer = true,
        columns = { "size", "mtime", "icon" },
        delete_to_trash = false,
        skip_confirm_for_simple_edits = false,
        view_options = { show_hidden = true },
      })

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

      local ts_ok, ts_configs = pcall(require, "nvim-treesitter.configs")
      if ts_ok then
        ts_configs.setup({
          auto_install = false,
          highlight = { enable = true },
          indent = { enable = true },
        })
      end

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
      pcall(require("telescope").load_extension, "fzf")

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

      local keymap = vim.keymap.set

      function vim.getVisualSelection()
        vim.cmd('noau normal! "vy"')
        local text = vim.fn.getreg("v")
        vim.fn.setreg("v", {})
        text = string.gsub(text, "\n", "")
        if #text > 0 then return text else return "" end
      end

      keymap("n", "<C-f>", function()
        require("telescope").extensions.live_grep_args.live_grep_args()
      end, { desc = "Live Grep Args" })

      keymap("i", "<C-f>", function()
        require("telescope").extensions.live_grep_args.live_grep_args()
      end, { desc = "Live Grep Args" })

      keymap("v", "<C-f>", function()
        local text = vim.getVisualSelection()
        require("telescope").extensions.live_grep_args.live_grep_args({ default_text = text })
      end, { desc = "Live Grep Args Selection" })

      function CopyRelativePath()
        local current_file = vim.fn.expand("%")
        local relative_path = vim.fn.fnamemodify(current_file, ":.")
        vim.fn.setreg("+", relative_path)
        print("Relative Path: " .. relative_path)
      end
      vim.api.nvim_set_keymap("n", "<leader>y", ":lua CopyRelativePath()<CR>", { noremap = true, silent = true })

      function ToggleFoldMethod()
        if vim.o.foldmethod == "indent" then
          vim.o.foldmethod = "marker"
        else
          vim.o.foldmethod = "indent"
        end
      end
      keymap("n", "ff", ":lua ToggleFoldMethod() <CR>", { silent = true })

      keymap({ "n", "v" }, "<Space>", "<Nop>", { silent = true })
      keymap("n", ";", ":", { silent = true })

      keymap("n", "<C-a>", "gg<S-v>G")
      keymap("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
      keymap("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

      keymap("n", "te", ":tabedit<CR>", { silent = true })
      keymap("n", "<tab>", ":bp<CR>", { silent = true })

      keymap("n", "ss", ":split<Return><C-w>w", { silent = true })
      keymap("n", "sv", ":vsplit<Return><C-w>w", { silent = true })

      keymap("n", "sh", "<C-w>h", { silent = true })
      keymap("n", "sl", "<C-w>l", { silent = true })
      keymap("n", "sk", "<C-w>k", { silent = true })
      keymap("n", "sj", "<C-w>j", { silent = true })

      keymap("x", "p", '"_dP', { noremap = true, silent = true })
      keymap("n", "<C-w>", ":bd<CR>", { silent = true })

      if vim.loop.os_uname().sysname == "Darwin" then
        keymap("n", "<C-/>", "<Plug>kommentary_line_default<CR>")
        keymap("v", "<C-/>", "<Plug>kommentary_visual_default<CR>")
        keymap("n", "<C-_>", "<Plug>kommentary_line_default<CR>")
        keymap("v", "<C-_>", "<Plug>kommentary_visual_default<CR>")
        vim.cmd [[ xmap <C-c> "*y ]]
      else
        keymap("n", "<C-_>", "<Plug>kommentary_line_default<CR>")
        keymap("v", "<C-_>", "<Plug>kommentary_visual_default<CR>")
        keymap("n", "<C-/>", "<Plug>kommentary_line_default<CR>")
        keymap("v", "<C-/>", "<Plug>kommentary_visual_default<CR>")
        vim.cmd [[ xmap <C-c> "+y ]]
      end
      keymap("n", "<C-p>", ":Telescope find_files hidden=true find_command=fd,--type,f,--exclude,.git<CR>")

      if vim.env.TMUX then
        keymap("n", "", "<Plug>kommentary_line_default<CR>")
        keymap("v", "", "<Plug>kommentary_visual_default<CR>")
      end

      keymap("n", "gs", ":vsplit | lua vim.lsp.buf.definition()<CR>", { silent = true })
      keymap({ "n", "v" }, "<leader>ca", ":lua require('actions-preview').code_actions()<CR>")
      keymap({ "n", "v" }, "<leader>gl", ":lua require('custom.github-helper').main()<CR>")
      keymap("n", "<leader>b", ":lua require('custom.bookmarks-picker').open()<CR>", { silent = true })

      keymap("n", "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>")
      keymap("n", "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>")
      keymap("n", "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>")
      keymap("n", "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>")

      local lspconfig = require("lspconfig")
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
      if ok_cmp then
        capabilities = cmp_lsp.default_capabilities(capabilities)
      end

      local servers = {
        lua_ls = {
          cmd = { "lua-language-server" },
          settings = {
            Lua = {
              diagnostics = { globals = { "vim" } },
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
            },
          },
        },
        pyright = { cmd = { "pyright-langserver", "--stdio" } },
        ts_ls = { cmd = { "typescript-language-server", "--stdio" } },
        bashls = { cmd = { "bash-language-server", "start" } },
        jsonls = { cmd = { "vscode-json-language-server", "--stdio" } },
        yamlls = { cmd = { "yaml-language-server", "--stdio" } },
        html = { cmd = { "vscode-html-language-server", "--stdio" } },
        cssls = { cmd = { "vscode-css-language-server", "--stdio" } },
        dockerls = { cmd = { "docker-langserver", "--stdio" } },
        nil_ls = { cmd = { "nil" } },
        sqls = { cmd = { "sqls" } },
        clangd = { cmd = { "clangd" } },
        jdtls = { cmd = { "jdtls" } },
        marksman = { cmd = { "marksman", "server" } },
        terraformls = { cmd = { "terraform-ls", "serve" } },
      }

      local configs = require("lspconfig.configs")
      local function setup_server(name, cfg)
        local ok, config = pcall(require, "lspconfig.configs." .. name)
        if not ok or not config then
          return
        end
        configs[name] = config
        local ok_cfg, server_cfg = pcall(function()
          return lspconfig[name]
        end)
        if not ok_cfg or not server_cfg then
          return
        end
        local exe = cfg.cmd and cfg.cmd[1] or nil
        if exe and vim.fn.executable(exe) ~= 1 then
          return
        end
        local merged = vim.tbl_deep_extend("force", { capabilities = capabilities }, cfg)
        pcall(server_cfg.setup, merged)
      end

      for server, cfg in pairs(servers) do
        setup_server(server, cfg)
      end
    '';
  };
}
