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

  dconf.settings."org/gnome/desktop/input-sources".xkb-options = [
    "grp_led:scroll"
    "ctrl:nocaps"
  ];

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

  # Ghostty advertises D-Bus activation, but its package does not provide the
  # systemd user unit expected by GNOME. Override the launcher so GNOME runs
  # the executable directly instead of failing on the missing unit.
  xdg.dataFile."applications/com.mitchellh.ghostty.desktop".text = ''
    [Desktop Entry]
    Version=1.0
    Name=Ghostty
    GenericName=Terminal Emulator
    Type=Application
    Comment=A terminal emulator
    TryExec=${pkgs.ghostty}/bin/ghostty
    Exec=${pkgs.ghostty}/bin/ghostty --gtk-single-instance=true
    Icon=com.mitchellh.ghostty
    Categories=System;TerminalEmulator;
    Keywords=terminal;tty;pty;
    StartupNotify=true
    StartupWMClass=com.mitchellh.ghostty
    Terminal=false
    DBusActivatable=false
    X-GNOME-UsesNotifications=true
  '';
}
