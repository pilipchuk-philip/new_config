{ pkgs, lib, ... }:

{
  imports = [ ./common.nix ];

  networking.hostName = "mac-work";
  system.primaryUser = "ppy";

  users.users.ppy = {
    home = "/Users/ppy";
    shell = pkgs.zsh;
  };

  system.keyboard = {
    remapCapsLockToEscape = lib.mkForce false;
    remapCapsLockToControl = true;
  };
}
