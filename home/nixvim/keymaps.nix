{ lib, ... }:

{
  programs.nixvim.extraConfigLua = lib.mkAfter ''
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
    keymap("n", "<C-p>", function() Snacks.picker.files({ hidden = true }) end, { desc = "Find Files" })

    if vim.env.TMUX then
      keymap("n", "\31", "<Plug>kommentary_line_default<CR>")
      keymap("v", "\31", "<Plug>kommentary_visual_default<CR>")
    end

    keymap("n", "gs", ":vsplit | lua vim.lsp.buf.definition()<CR>", { silent = true })
    keymap({ "n", "v" }, "<leader>ca", ":lua require('actions-preview').code_actions()<CR>")
    keymap({ "n", "v" }, "<leader>gl", ":lua require('custom.github-helper').main()<CR>")
    keymap("n", "<leader>b", ":lua require('custom.bookmarks-picker').open()<CR>", { silent = true })
    keymap("n", "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>")
    keymap("n", "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>")
    keymap("n", "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>")
    keymap("n", "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>")
  '';
}
