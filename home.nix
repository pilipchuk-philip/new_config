{ pkgs, ... }:

{
  imports = [ ./home.common.nix ];

  home.packages = with pkgs; [
    steam
    steam-run          # иногда спасает старые бинарники
    mangohud           # FPS/frametime overlay
    gamemode           # Feral GameMode
    vkbasalt           # optional: post-processing
    ghostty
    vulkan-tools
    mullvad-vpn
    jetbrains.pycharm
    kdePackages.francis
    kdiff3
    thunderbird-bin
    krename
    krusader
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
