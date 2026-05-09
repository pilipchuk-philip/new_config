{ ... }:

{
  imports = [ ./darwin-common.nix ];

  home.username = "ppy";
  home.homeDirectory = "/Users/ppy";

  programs.git.settings.user = {
    name = "pilipchuk-philip";
    email = "ppy@csis.com";
  };

  programs.git.settings.push.default = "current";
  programs.git.settings.gpg.format = "ssh";
  programs.git.settings.user.signingkey = "~/.ssh/id_ed25519.pub";
  programs.git.settings.commit.gpgsign = true;
}
