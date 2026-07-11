{ lib, ... }:

{
  programs.nixvim.extraConfigLua = lib.mkAfter ''
    local format_on_save = require("format-on-save")
    local formatters = require("format-on-save.formatters")
    local prettier = formatters.shell({ cmd = { "prettier", "--stdin-filepath", "%" } })

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
        python = {
          formatters.remove_trailing_whitespace,
          formatters.shell({ cmd = { "ruff", "format", "-" } }),
        },
        go = {
          formatters.shell({
            cmd = { "goimports-reviser", "-rm-unused", "-set-alias", "-format", "%" },
            tempfile = function() return vim.fn.expand("%") .. ".formatter-temp" end,
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
    vim.api.nvim_create_autocmd("BufWritePost", {
      group = vim.api.nvim_create_augroup("LintOnSave", { clear = true }),
      callback = function() require("lint").try_lint() end,
    })
  '';
}
