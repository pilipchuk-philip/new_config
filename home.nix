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

  home.packages =
    (builtins.attrValues {
      inherit (pkgs)
        thunderbird-bin
        unrar
        signal-desktop
        telegram-desktop
        spotify
        # clipboard helpers (на Wayland/X11)
        wl-clipboard
        xclip
        ;
    })
    ++ [
      pkgs.kdePackages.francis
    ];
}
