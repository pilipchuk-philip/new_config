{ pkgs, ... }:

let
  formatOnSave = pkgs.vimUtils.buildVimPlugin {
    pname = "format-on-save.nvim";
    version = "local";
    src = ../../vendor/format-on-save.nvim;
  };
  vimPluginRuscmd = pkgs.vimUtils.buildVimPlugin {
    pname = "vim-plugin-ruscmd";
    version = "local";
    src = ../../vendor/vim-plugin-ruscmd;
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
  nvimLint = pkgs.vimPlugins.nvim-lint.overrideAttrs (_old: {
    src = pkgs.fetchFromGitHub {
      owner = "mfussenegger";
      repo = "nvim-lint";
      rev = "a219b2c9e5b4765e5c845aba119dad55806fcaf1";
      sha256 = "05fk4rybn4b4ffnq0xpk54l81q7dz3f9dpj2zh9i0wv46k6n2054";
    };
  });
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
  nixpkgs.config.allowUnfree = true;

  programs.nixvim = {
    extraPlugins =
      (builtins.attrValues {
        inherit (pkgs.vimPlugins)
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
          nvim-lspconfig
          nvim-web-devicons
          plenary-nvim
          render-markdown-nvim
          snacks-nvim
          sqlite-lua
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
          vim-sleuth
          vim-tmux-navigator
          wilder-nvim
          dropbar-nvim
          ;
      })
      ++ [
        formatOnSave
        nvimLint
        treesitterWithParsers
        vimPluginRuscmd
        smartPaste
      ];

    extraFiles = {
      "lua/custom/bookmarks-picker.lua".text = builtins.readFile ../../vendor/bookmarks-picker.lua;
      "lua/custom/github-helper.lua".text = builtins.readFile ../../vendor/github-helper.lua;
    };
  };
}
