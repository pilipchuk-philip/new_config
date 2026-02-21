{ pkgs, ... }:

{
  imports = [ ./home.common.nix ];

  home.packages = with pkgs; [
    codex
    ghostty
  ];

  targets.darwin.copyApps.enable = true;
  targets.darwin.linkApps.enable = false;
}
