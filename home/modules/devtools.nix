{
  config,
  pkgs,
  lib,
  ...
}:

let
  localScripts = import ../../pkgs/scripts.nix { inherit pkgs; };
in
{
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    package =
      if pkgs.stdenv.isDarwin then
        pkgs.direnv.overrideAttrs (_: {
          doCheck = false;
        })
      else
        pkgs.direnv;
  };

  programs.git = {
    enable = true;
    settings = {
      alias = {
        lg = "log --graph --decorate --pretty=format:'%C(auto)%h %C(bold blue)%an%Creset %C(auto)%d %s'";
        gs = "status";
      };
    };
  };

  home.packages =
    with pkgs;
    (lib.optionals stdenv.isLinux [
      cifs-utils
    ])
    ++ [
      git
      ripgrep
      fd
      lsd
      unzip
      gcc
      wget
      gnumake
      zip
      tmux
      btop
      fzf
      lazygit
      age
      sops
      luajit
      rsync
      nodejs
      tree-sitter
      uv
      python313

      # LSP servers
      lua-language-server
      pyright
      typescript-language-server
      bash-language-server
      vscode-langservers-extracted
      yaml-language-server
      dockerfile-language-server
      nil
      sqls
      llvmPackages.clang-tools
      jdt-language-server
      marksman
      terraform-ls

      # format-on-save tools
      nixfmt
      ruff
      prettier
      shfmt
      go
      goimports-reviser
      vale
      valeStyles.proselint
      mypy
      imagemagick
      ghostscript
      tectonic
      mermaid-cli
      gh
      lynx
      rustc
      cargo
    ]
    ++ localScripts;

  xdg.configFile."vale/styles".source = pkgs.valeStyles.proselint;

  home.file.".vale.ini".text = ''
    StylesPath = ${config.xdg.configHome}/vale/styles
    MinAlertLevel = suggestion

    [*.md]
    BasedOnStyles = proselint
  '';
}
