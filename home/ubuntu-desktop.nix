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
    pkgs.claude-code
    pkgs.ghostty
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.ollama
    pkgs.steam
    pkgs.steam-run
    pkgs.mangohud
    pkgs.gamemode
    pkgs.vkbasalt
    pkgs.vulkan-tools
    pkgs.mullvad-vpn
    pkgs.tailscale
    pkgs.tailscale-systray
  ];
}
