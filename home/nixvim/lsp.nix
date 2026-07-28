{ lib, ... }:

{
  programs.nixvim.extraConfigLua = lib.mkAfter ''
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
      if not ok or not config then return end
      configs[name] = config
      local ok_cfg, server_cfg = pcall(function() return lspconfig[name] end)
      if not ok_cfg or not server_cfg then return end
      local exe = cfg.cmd and cfg.cmd[1] or nil
      if exe and vim.fn.executable(exe) ~= 1 then return end
      local merged = vim.tbl_deep_extend("force", { capabilities = capabilities }, cfg)
      pcall(server_cfg.setup, merged)
    end

    for server, cfg in pairs(servers) do
      setup_server(server, cfg)
    end

    -- Глобальный фильтр LSP-диагностик по подстроке в сообщении.
    -- Добавляй новые паттерны в ignored_diagnostic_patterns.
    local ignored_diagnostic_patterns = {
      "union syntax cannot be used with string operand",
    }

    local orig_handler = vim.lsp.handlers["textDocument/publishDiagnostics"]
    vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
      if result and result.diagnostics then
        result.diagnostics = vim.tbl_filter(function(d)
          local msg = (d.message or ""):lower()
          for _, pat in ipairs(ignored_diagnostic_patterns) do
            if msg:find(pat, 1, true) then
              return false
            end
          end
          return true
        end, result.diagnostics)
      end
      return orig_handler(err, result, ctx, config)
    end
  '';
}
