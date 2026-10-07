{ pkgs, ... }:

let
  # IPTV Simple also includes adaptive, FFmpeg Direct and RTMP input modules.
  kodi = pkgs.kodi.withPackages (addons: [ addons.pvr-iptvsimple ]);

  # Use Apple's original downloads, pinned independently of Homebrew's latest casks.
  mkAppleFont =
    {
      pname,
      url,
      hash,
      installer,
      payload,
    }:
    pkgs.stdenvNoCC.mkDerivation {
      inherit pname;
      version = "2026-10-06";
      src = pkgs.fetchurl { inherit url hash; };
      nativeBuildInputs = [
        pkgs._7zz
        pkgs.libarchive
      ];
      unpackPhase = ''
        runHook preUnpack
        7zz x -y "$src" -odmg
        mkdir package fonts
        bsdtar -xf "dmg/${installer}" -C package
        bsdtar -xf "package/${payload}/Payload" -C fonts
        runHook postUnpack
      '';
      installPhase = ''
        runHook preInstall
        mkdir -p "$out/share/fonts/opentype" "$out/share/fonts/truetype"
        install -m644 fonts/Library/Fonts/*.otf "$out/share/fonts/opentype/"
        for font in fonts/Library/Fonts/*.ttf; do
          if [ -f "$font" ]; then
            install -m644 "$font" "$out/share/fonts/truetype/"
          fi
        done
        mkdir -p "$out/share/doc/${pname}"
        cp -r package/Resources "$out/share/doc/${pname}/"
        runHook postInstall
      '';
      meta = {
        homepage = "https://developer.apple.com/fonts/";
        license = pkgs.lib.licenses.unfree;
        platforms = pkgs.lib.platforms.linux;
      };
    };
in
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
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [ "SF Pro Text" ];
      monospace = [
        "SF Mono"
        "JetBrainsMono Nerd Font"
      ];
    };
    # Modern macOS uses grayscale antialiasing and preserves glyph outlines.
    antialiasing = true;
    hinting = "none";
    subpixelRendering = "none";
  };
  home.username = "q";
  home.homeDirectory = "/home/q";

  dconf.settings = {
    "org/gnome/desktop/peripherals/mouse".natural-scroll = true;
    "org/gnome/desktop/peripherals/touchpad".natural-scroll = true;
    "org/gnome/desktop/input-sources".xkb-options = [
      "grp_led:scroll"
      "ctrl:nocaps"
    ];
    "org/gnome/desktop/interface" = {
      font-name = "SF Pro Text 11";
      document-font-name = "SF Pro Text 11";
      monospace-font-name = "SF Mono 11";
      font-antialiasing = "grayscale";
      font-hinting = "none";
    };
    "org/gnome/desktop/wm/preferences".titlebar-font = "SF Pro Display Bold 11";
  };

  gtk = {
    enable = true;
    font = {
      name = "SF Pro Text";
      size = 11;
    };
  };

  xdg.configFile."ghostty/config.ghostty".text = ''
    font-family = SF Mono
  '';

  home.packages = [
    (mkAppleFont {
      pname = "sf-pro";
      url = "https://devimages-cdn.apple.com/design/resources/download/SF-Pro.dmg";
      hash = "sha256-loqzuLH5LC2K9h6waA9cIiTE541ZuYa/AEUCp/wBKRg=";
      installer = "SFProFonts.pkg";
      payload = "SFProFontsPackage.pkg";
    })
    (mkAppleFont {
      pname = "sf-mono";
      url = "https://devimages-cdn.apple.com/design/resources/download/SF-Mono.dmg";
      hash = "sha256-bUoLeOOqzQb5E/ZCzq0cfbSvNO1IhW1xcaLgtV2aeUU=";
      installer = "SFMonoFonts/SF Mono Fonts.pkg";
      payload = "SFMonoFonts.pkg";
    })
    # pkgs._1password-cli
    # pkgs._1password-gui
    pkgs.codex
    pkgs.claude-code
    pkgs.ghostty
    kodi
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

  # Register directly in the user's menu, independently of GNOME's Nix environment.
  xdg.dataFile."applications/kodi.desktop".text = ''
    [Desktop Entry]
    Version=1.0
    Type=Application
    Name=Kodi
    GenericName=Media Center
    Comment=IPTV and media player
    Exec=${kodi}/bin/kodi
    Icon=${kodi}/share/icons/hicolor/256x256/apps/kodi.png
    Terminal=false
    Categories=AudioVideo;Video;Player;TV;
    StartupNotify=true
  '';

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
