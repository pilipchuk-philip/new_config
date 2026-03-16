{ pkgs, ... }:

{
  imports = [ ./common.nix ];

  networking.hostName = "mac";
  system.primaryUser = "q";

  homebrew.enable = true;
  homebrew.onActivation.autoUpdate = true;
  homebrew.onActivation.upgrade = true;
  homebrew.onActivation.cleanup = "zap";

  homebrew.brews = [
    "postgresql@16"
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
