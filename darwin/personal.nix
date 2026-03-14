{ pkgs, ... }:

{
  imports = [ ./common.nix ];

  networking.hostName = "mac";
  system.primaryUser = "q";

  homebrew.casks = [
    "ghostty"
    "codex"
  ];

  users.users.q = {
    home = "/Users/q";
    shell = pkgs.zsh;
  };
}
