{ pkgs, ... }:

{
  imports = [ ../home.nix ];

  targets.genericLinux.enable = true;
  fonts.fontconfig.enable = true;
  home.username = "q";
  home.homeDirectory = "/home/q";

  home.packages = [
    # pkgs._1password-cli
    # pkgs._1password-gui
    pkgs.codex
    pkgs.ghostty
    pkgs.nerd-fonts.jetbrains-mono
  ];
}
