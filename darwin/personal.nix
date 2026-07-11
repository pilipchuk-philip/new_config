{ pkgs, ... }:

{
  imports = [ ./common.nix ];

  networking.hostName = "mac";
  system.primaryUser = "q";

  homebrew.enable = true;
  homebrew.onActivation.autoUpdate = false;
  homebrew.onActivation.upgrade = false;
  homebrew.onActivation.cleanup = "uninstall";

  homebrew.brews = [
    "postgresql@16"
    "pgcli"
  ];

  homebrew.casks = [
    "ghostty"
    "codex"
  ];

  users.users.q = {
    home = "/Users/q";
    shell = pkgs.zsh;
  };
}
