{ ... }:

{
  imports = [ ./darwin-common.nix ];

  home.username = "q";
  home.homeDirectory = "/Users/q";

  programs.git.settings.user = {
    name = "pilipchuk-philip";
    email = "pilipchuk.philip@gmail.com";
  };

  programs.zsh.initContent = ''
    export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"
  '';
}
