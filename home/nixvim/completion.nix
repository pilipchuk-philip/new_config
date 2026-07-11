{ lib, ... }:

{
  programs.nixvim.extraConfigLua = lib.mkAfter ''
    require("nvim-autopairs").setup({
      disable_filetype = { "TelescopePrompt", "spectre_panel" },
    })
    require("snippy").setup({})

    local cmp = require("cmp")
    local lspkind = require("lspkind")
    lspkind.init({ symbol_map = { Copilot = "" } })
    cmp.setup({
      snippet = {
        expand = function(args) require("snippy").expand_snippet(args.body) end,
      },
      window = {
        completion = { border = "rounded", scrollbar = true },
        documentation = { border = "rounded", scrollbar = "║" },
      },
      preselect = cmp.PreselectMode.None,
      formatting = {
        fields = { cmp.ItemField.Kind, cmp.ItemField.Abbr, cmp.ItemField.Menu },
        expandable_indicator = true,
        format = lspkind.cmp_format({ mode = "symbol_text", maxwidth = 50, ellipsis_char = "..." }),
      },
      mapping = {
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<Down>"] = cmp.mapping(cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }), { "i" }),
        ["<Up>"] = cmp.mapping(cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }), { "i" }),
        ["<C-c>"] = cmp.mapping.close(),
        ["<CR>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false }),
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            if not cmp.get_selected_entry() then
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
        { name = "nvim_lsp" }, { name = "copilot" }, { name = "nvim_lua" },
        { name = "path" }, { name = "buffer" }, { name = "snippy" },
      },
    })

    local cmp_autopairs = require("nvim-autopairs.completion.cmp")
    cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    require("copilot").setup({ suggestion = { enabled = false }, panel = { enabled = false } })
    require("copilot_cmp").setup()
  '';
}
