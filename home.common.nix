{ config, ... }:

{
  imports = [
    ./home/modules/shell.nix
    ./home/modules/devtools.nix
    ./home/modules/terminal.nix
    ./nixvim.nix
    ./vscode.nix
    ./tmux.nix
  ];

  home.stateVersion = "25.11";
  programs.home-manager.enable = true;

  xdg.enable = true;
  sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

  home.file.".config/p10k.zsh".source = ./p10k.zsh;

  programs.zsh = {
    enable = true;
    dotDir = config.home.homeDirectory;
    oh-my-zsh = {
      enable = true;
      theme = "";
      plugins = [
        "git"
        "sudo"
        "docker"
      ];
    };
    autosuggestion.enable = true;
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
      if [ -d /etc/nixos/scripts ]; then
        export PATH="/etc/nixos/scripts:$PATH"
      elif [ -d "${config.home.homeDirectory}/new_config/scripts" ]; then
        export PATH="${config.home.homeDirectory}/new_config/scripts:$PATH"
      fi
      export PATH="$(npm config get prefix)/bin:$PATH"
      eval "$(uv generate-shell-completion zsh)"
      eval "$(uvx --generate-shell-completion zsh)"
      export POWERLEVEL9K_CONFIG_FILE=${config.xdg.configHome}/p10k.zsh
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      source ${config.xdg.configHome}/p10k.zsh
    '';
    syntaxHighlighting.enable = true;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    package = if pkgs.stdenv.isDarwin then
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
  xdg.configFile."ghostty/config".text = ''
    term = xterm-256color
    theme = Catppuccin Mocha
    cursor-style = block
    cursor-style-blink = false
    copy-on-select = clipboard
    clipboard-read = allow
    clipboard-write = allow
  '';

  home.file.".vale.ini".text = ''
    StylesPath = ${config.xdg.configHome}/vale/styles
    MinAlertLevel = suggestion

    [*.md]
    BasedOnStyles = proselint
  '';

  home.activation.codexStatusLine = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    codex_config="$HOME/.codex/config.toml"
    codex_status_line='status_line = ["model", "current-dir", "context-used", "context-window-size", "five-hour-limit", "weekly-limit", "used-tokens"]'

    mkdir -p "$HOME/.codex"
    if [ ! -f "$codex_config" ]; then
      printf '[tui]\n%s\n' "$codex_status_line" > "$codex_config"
      chmod 600 "$codex_config"
    elif grep -q '^\[tui\]$' "$codex_config"; then
      ${pkgs.perl}/bin/perl -0pi -e '
        my $line = q{status_line = ["model", "current-dir", "context-used", "context-window-size", "five-hour-limit", "weekly-limit", "used-tokens"]};
        s{^\[tui\]\n(?:status_line = \[.*?\]\n)?}{\[tui\]\n$line\n}ms
          or s{\z}{\n[tui]\n$line\n}ms;
      ' "$codex_config"
    else
      printf '\n[tui]\n%s\n' "$codex_status_line" >> "$codex_config"
    fi
  '';

  home.activation.zshCompletionCacheCleanup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    rm -f "$HOME"/.zcompdump "$HOME"/.zcompdump-* "$HOME"/.zcompdump*.zwc
  '';
}
