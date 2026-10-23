{ pkgs }:

let
  theme = pkgs.stdenvNoCC.mkDerivation {
    pname = "matrices-window-grub-theme";
    version = "2025-03-14";
    src = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/yeyushengfan258/Matrix-grub-theme/3aed8ee042e540246ee5b02d61d21c1d7889a208/releases/Matrices-window-grub-themes.tar.xz";
      hash = "sha256-J0gkTrPULxr9z+E6y4Jbdd+4MwH0e3pVrHpsrwEsaJk=";
    };
    installPhase = ''
      runHook preInstall
      mkdir -p "$out"
      cp -r 1080p/Matrices-window/. "$out/"
      runHook postInstall
    '';
  };
  grubConfig = pkgs.writeText "matrices-window.cfg" ''
    GRUB_THEME="/boot/grub/themes/Matrices-window/theme.txt"
    GRUB_BACKGROUND="/boot/grub/themes/Matrices-window/background.jpg"
    GRUB_GFXMODE="1920x1080,auto"
    GRUB_TERMINAL_OUTPUT="gfxterm"
    GRUB_DEFAULT="osprober-efi-8CD0-8886"
    GRUB_DISABLE_MEMTEST=true
    # Other operating systems are generated earlier by 09_os-prober-first.
    GRUB_DISABLE_OS_PROBER=true
  '';
  osProberFirst = pkgs.writeText "09_os-prober-first" ''
    #!/bin/sh
    # Reuse Ubuntu's maintained generator before 10_linux, without duplicates.
    GRUB_DISABLE_OS_PROBER=false exec /etc/grub.d/30_os-prober
  '';
in
pkgs.writeShellApplication {
  name = "ubuntu-grub-theme-setup";
  runtimeInputs = [ pkgs.coreutils ];
  text = ''
    test -f /etc/default/grub
    test -d /boot/grub
    test -x /usr/sbin/update-grub
    test -x /etc/grub.d/30_os-prober
    /usr/bin/sudo -v

    # Copy assets onto /boot: GRUB cannot rely on access to the Nix store.
    /usr/bin/sudo install -d -m755 /boot/grub/themes/Matrices-window /etc/default/grub.d
    /usr/bin/sudo cp -r --no-preserve=ownership ${theme}/. /boot/grub/themes/Matrices-window/
    /usr/bin/sudo chmod -R u=rwX,go=rX /boot/grub/themes/Matrices-window
    /usr/bin/sudo install -b --backup=numbered -m644 ${grubConfig} /etc/default/grub.d/zz-matrices-window.cfg
    /usr/bin/sudo install -b --backup=numbered -m755 ${osProberFirst} /etc/grub.d/09_os-prober-first
    /usr/bin/sudo /usr/sbin/update-grub
    /usr/bin/sudo /usr/bin/grub-script-check /boot/grub/grub.cfg
    /usr/bin/sudo /usr/bin/grep -F 'set theme=' /boot/grub/grub.cfg
    /usr/bin/sudo /usr/bin/grep -E "^[[:space:]]*(menuentry |submenu )" /boot/grub/grub.cfg
    printf '%s\n' 'Matrices Window установлена. Тема появится при следующей загрузке.'
  '';
}
