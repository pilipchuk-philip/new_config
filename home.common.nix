{ config, pkgs, lib, ... }:

let
  localScripts = import ./pkgs/scripts.nix { inherit pkgs; };
in
{
  imports = [
    ./nixvim.nix
    ./vscode.nix
  ];

  home.stateVersion = "25.11";
  programs.home-manager.enable = true;

  xdg.enable = true;
  sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

  home.file.".config/p10k.zsh".source = ./p10k.zsh;

  programs.zsh = {
    enable = true;
    shellAliases = {
      ls = "lsd";
      tree = "ls --tree";
      gs = "git status";
      gamen = "git add . && git commit --amend";
      cp = "rsync -aP";
      lg = "lazygit";
      rg = "rg -S --hidden";
      gc = "git branch --sort=committerdate | fzf --header 'Checkout Recent Branch' --preview 'git diff {0} --color=always' --pointer='=>' | xargs git checkout";
      fd = "fd --hidden --color always -i ";
    };
    initContent = ''
      export PATH="$(npm config get prefix)/bin:$PATH"
      export POWERLEVEL9K_CONFIG_FILE=${config.xdg.configHome}/p10k.zsh
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      source ${config.xdg.configHome}/p10k.zsh
    '';
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "pilipchuk-philip";
        email = "pilipchuk.philip@gmail.com";
      };
      alias = {
        lg = "log --oneline --graph --decorate";
        gs = "status";
      };
    };
  };

  # Набор базовых утилит, которые почти всегда нужны в nvim-воркфлоу
  home.packages = with pkgs;
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
    uv
    python313

    # LSP servers
    lua-language-server
    pyright
    nodePackages.typescript-language-server
    nodePackages.bash-language-server
    nodePackages.vscode-langservers-extracted
    nodePackages.yaml-language-server
    dockerfile-language-server
    nil
    sqls
    llvmPackages.clang-tools
    jdt-language-server
    marksman
    terraform-ls

    # format-on-save tools
    ruff
    nodePackages.prettier
    shfmt
    go
    goimports-reviser
    vale
    valeStyles.proselint
    mypy
    # Под вопросом, это нужно было для старого nvim
    sqlite
    tree-sitter
    imagemagick
    ghostscript
    tectonic
    nodePackages.mermaid-cli
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
