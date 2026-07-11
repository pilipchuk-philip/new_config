{ pkgs, lib, ... }:

{
  imports = [
    ./home.common.nix
    ./home/modules/toolchains.nix
  ];

  my.toolchains.enable = true;

  programs.git.settings.user = {
    name = "pilipchuk-philip";
    email = "pilipchuk.philip@gmail.com";
  };

  home.packages = with pkgs; [
    kdePackages.francis
    thunderbird-bin
    unrar
    signal-desktop
    telegram-desktop
    spotify
    # clipboard helpers (на Wayland/X11)
    wl-clipboard
    xclip
  ];
}
