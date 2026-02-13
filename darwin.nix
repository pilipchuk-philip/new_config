{ pkgs, ... }:

{
  system.stateVersion = 5;

  nix.enable = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;

  security.pam.services.sudo_local.touchIdAuth = true;

  system.primaryUser = "q";

  system.defaults = {
    NSGlobalDomain = {
      ApplePressAndHoldEnabled = false;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
  };

  fonts.packages = with pkgs; [
    jetbrains-mono
    nerd-fonts.jetbrains-mono
  ];

  users.users.q = {
    home = "/Users/q";
    shell = pkgs.zsh;
  };
}
