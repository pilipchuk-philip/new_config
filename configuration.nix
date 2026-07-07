{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      "q"
    ];
    allowed-users = [ "q" ];
    sandbox = true;
    substituters = [ "https://cache.nixos.org" ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings = {
    General = {
      Enable = "Source,Sink,Media,Socket";
    };
  };
  services.blueman.enable = true;

  # Bootloader
  boot.loader.timeout = 5;
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;
  boot.plymouth.enable = true;
  boot.plymouth.theme = "spinner";
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel / GPU
  boot.blacklistedKernelModules = [ "nouveau" ];
  boot.extraModprobeConfig = ''
    blacklist nouveau
    options nouveau modeset=0
  '';

  boot.kernelParams = [
    "quiet"
    "loglevel=3"
    "nvidia-drm.modeset=1"
    "usbhid.quirks=0x05ac:0x0503:0x0004"
  ];

  # Подгружаем модули NVIDIA пораньше (часто лечит black screen)
  boot.initrd.kernelModules = [
    "nvidia"
    "nvidia_modeset"
    "nvidia_uvm"
    "nvidia_drm"
  ];

  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];

    xkb = {
      layout = "us,ru";
      variant = "";
      options = "grp:alt_space_toggle,caps:escape";
    };
  };

  hardware.nvidia = {
    modesetting.enable = true;

    # На этапе стабилизации лучше выключить PM (частая причина зависона/чёрного экрана)
    powerManagement.enable = true;
    powerManagement.finegrained = false; # можно оставить закомментированным

    open = true;
    nvidiaSettings = true;
    gsp.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.production;
  };

  # NixOS 25.11: вместо hardware.opengl используем hardware.graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # VAAPI + Chrome SSO
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    CHROME_PASSWORD_STORE = "gnome-libsecret";
    NVD_BACKEND = "direct";
    __GL_THREADED_OPTIMIZATIONS = "1";
    __GL_MaxFramesAllowed = "1";
  };

  environment.systemPackages = with pkgs; [
    git
    google-chrome
    nvidia-vaapi-driver
    libva
    libva-utils
    mesa-demos
    pciutils
    usbutils
    qt6.qtmultimedia
    neovim
    codex
  ];

  # Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ ];
    allowedUDPPorts = [ ];
  };

  # Locale / Time
  time.timeZone = "Europe/Copenhagen";
  i18n.defaultLocale = "en_US.UTF-8";

  # Sound
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # User
  users.users.q = {
    isNormalUser = true;
    description = "q";
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
    ];
    packages = with pkgs; [
      xed-editor
    ];
  };

  users.users.root = {
    shell = pkgs.zsh;
  };

  # Font
  fonts.packages = with pkgs; [
    jetbrains-mono
    nerd-fonts.jetbrains-mono
  ];

  # Programs
  #  programs.firefox.enable = true;
  programs.gamemode.enable = true;
  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      #theme = "powerlevel10k/powerlevel10k";
      plugins = [
        "git"
        "sudo"
        "docker"
        "zsh-autosuggestions"
        "zsh-syntax-highlighting"
      ];
    };
    promptInit = ''
      export POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
      export POWERLEVEL9K_CONFIG_FILE=${./p10k.zsh}
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
    '';
  };
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "q" ];
  };

  # Security hardening
  security.apparmor.enable = true;
  security.sudo.wheelNeedsPassword = true;
  users.users.root.hashedPassword = "!";

  boot.kernel.sysctl = {
    "kernel.kptr_restrict" = 2;
    "kernel.dmesg_restrict" = 1;
    "kernel.yama.ptrace_scope" = 1;
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv4.conf.all.send_redirects" = 0;
    "net.ipv4.conf.default.send_redirects" = 0;
    "net.ipv4.tcp_syncookies" = 1;
  };

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.11";
  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
    dates = "daily";
    flake = "/etc/nixos";
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 10d";
  };
  nix.settings.auto-optimise-store = true;

}
