{ pkgs, ... }:

{
  imports = [ ./common.nix ];

  networking.hostName = "mac";
  system.primaryUser = "q";

  homebrew.enable = true;
  homebrew.caskArgs.no_quarantine = true;
  homebrew.onActivation.autoUpdate = true;
  homebrew.onActivation.upgrade = true;
  homebrew.onActivation.cleanup = "zap";

  homebrew.casks = [
    "ghostty"
    "codex"
    "postgresql@16"
  ];

  users.users.q = {
    home = "/Users/q";
    shell = pkgs.zsh;
  };
}
