{ pkgs, ... }:

{
  imports = [ ../home.nix ];

  targets.genericLinux.enable = true;
  targets.genericLinux.gpu.packages = import pkgs.path {
    system = pkgs.stdenv.hostPlatform.system;
    config = {
      allowUnfree = true;
      nvidia.acceptLicense = true;
    };
  };
  targets.genericLinux.gpu.nvidia = {
    enable = true;
    # Must match the Ubuntu host driver; update the version and hash together.
    version = "595.91.07";
    sha256 = "sha256-yiPIjdJLB6GRZE4eEc+3vN11NzBXSa9A+YABiwleYxM=";
  };
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
