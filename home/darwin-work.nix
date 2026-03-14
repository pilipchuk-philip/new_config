{ ... }:

{
  imports = [ ./darwin-common.nix ];

  home.username = "ppy";
  home.homeDirectory = "/Users/ppy";

  programs.git.settings.user = {
    name = "pilipchuk-philip";
    email = "ppy@csis.com";
  };
}
