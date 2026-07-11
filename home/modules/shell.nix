{ config, pkgs, ... }:

let
  uvCompletions = pkgs.runCommand "uv-zsh-completions" { } ''
    mkdir -p "$out"
    ${pkgs.uv}/bin/uv generate-shell-completion zsh > "$out/_uv"
    ${pkgs.uv}/bin/uvx --generate-shell-completion zsh > "$out/_uvx"
  '';
in

{
  home.file.".config/p10k.zsh".source = ../../p10k.zsh;
  xdg.configFile."zsh/completions".source = uvCompletions;

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
      fpath=("${config.xdg.configHome}/zsh/completions" $fpath)
      export POWERLEVEL9K_CONFIG_FILE=${config.xdg.configHome}/p10k.zsh
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      source ${config.xdg.configHome}/p10k.zsh
    '';
    syntaxHighlighting.enable = true;
  };
}
