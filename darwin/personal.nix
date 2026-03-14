{ pkgs, ... }:

{
  imports = [ ./common.nix ];

  networking.hostName = "mac";
  system.primaryUser = "q";

  users.users.q = {
    home = "/Users/q";
    shell = pkgs.zsh;
  };
}
