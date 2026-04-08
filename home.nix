{ pkgs, lib, ... }:

{
  imports = [ ./home.common.nix ];

  programs.git.settings.user = {
    name = "pilipchuk-philip";
    email = "pilipchuk.philip@gmail.com";
  };

  home.packages = with pkgs; [
    steam
    steam-run          # иногда спасает старые бинарники
    mangohud           # FPS/frametime overlay
    gamemode           # Feral GameMode
    vkbasalt           # optional: post-processing
    vulkan-tools
    mullvad-vpn
    jetbrains.pycharm
    kdePackages.francis
    thunderbird-bin
    unrar
    signal-desktop
    telegram-desktop
    spotify
    tailscale
    tailscale-systray

    # clipboard helpers (на Wayland/X11)
    wl-clipboard
    xclip
  ];
}
