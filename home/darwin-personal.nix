{ ... }:

{
  imports = [ ./darwin-common.nix ];

  home.username = "q";
  home.homeDirectory = "/Users/q";

  programs.git.settings.user = {
    name = "pilipchuk-philip";
    email = "pilipchuk.philip@gmail.com";
  };
}
