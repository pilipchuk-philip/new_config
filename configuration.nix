{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings = {
    General = {
      Enable = "Source,Sink,Media,Socket";
    };
  };
  services.blueman.enable = true;

  # Bootloader
  boot.loader.timeout = 0;
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
  boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];

  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];

    xkb = {
      layout = "us,ru";
      variant = "";
      options = "grp:win_space_toggle,ctrl:nocaps";
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

  systemd.services.nvidia-persistence = {
    description = "Enable NVIDIA persistence mode";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/run/current-system/sw/bin/nvidia-smi -pm 1";
    };
  };


  # NixOS 25.11: вместо hardware.opengl используем hardware.graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # KDE Plasma 6 (X11 only)
  services.displayManager.sddm = {
    enable = true;
    # wayland.enable = false;

    settings = {
      General = {
        DisplayServer = "x11";
      };
      Theme = {
        ThemeDir = "/etc/sddm/themes";
        Current = "astronaut";
      };
    };
  };

  services.displayManager.defaultSession = "plasmax11";
  services.desktopManager.plasma6.enable = true;

  # VAAPI + Chrome SSO
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    CHROME_PASSWORD_STORE = "kwallet6";
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
    kdePackages.sddm-kcm
    qt6.qtmultimedia
    neovim
    kdePackages.kconfig
    codex
  ];

  # Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

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
    extraGroups = [ "networkmanager" "wheel" "video" ];
    packages = with pkgs; [
      kdePackages.kate
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
      plugins = [ "git" "sudo" "docker" ];
    };
    promptInit = ''
      export POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
      export POWERLEVEL9K_CONFIG_FILE=/etc/nixos/p10k.zsh
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

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.11";
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 10d";
  };
  nix.settings.auto-optimise-store = true;


}
