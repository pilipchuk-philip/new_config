{ config, pkgs, ... }:

{
  imports = [ ./nixvim.nix ];

  home.stateVersion = "25.11";
  programs.home-manager.enable = true;

  xdg.enable = true;

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
    };
    initExtra = ''
      export POWERLEVEL9K_CONFIG_FILE=/etc/nixos/p10k.zsh
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      source /etc/nixos/p10k.zsh
    '';
  };

  programs.git = {
    enable = true;
    settings = {
      alias = {
        lg = "log --oneline --graph --decorate";
        gs = "status";
      };
    };
  };

  # Набор базовых утилит, которые почти всегда нужны в nvim-воркфлоу
  home.packages = with pkgs; [
    git
    ripgrep
    fd
    lsd
    unzip
    gcc
    wget
    gnumake
    steam
    steam-run          # иногда спасает старые бинарники
    mangohud           # FPS/frametime overlay
    gamemode           # Feral GameMode
    vkbasalt           # optional: post-processing
    ghostty
    vulkan-tools
    pkgs.signal-desktop
    pkgs.telegram-desktop
    pkgs.signal-desktop
    pkgs.vscode
    pkgs.spotify
    pkgs.tailscale
    pkgs.tailscale-systray
    tmux
    pkgs.btop
    pkgs.fzf
    pkgs.lazygit
    pkgs.luajit
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

  # clipboard helpers (на Wayland/X11)
  wl-clipboard
  xclip
  ];

  xdg.configFile."vale/styles".source = pkgs.valeStyles.proselint;
  home.file.".vale.ini".text = ''
    StylesPath = ${config.xdg.configHome}/vale/styles
    MinAlertLevel = suggestion

    [*.md]
    BasedOnStyles = proselint
  '';
}
