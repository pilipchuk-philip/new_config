{ config, pkgs, ... }:

{
  home.file.".config/p10k.zsh".source = ../../p10k.zsh;

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
}
