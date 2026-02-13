{ pkgs, ... }:

{
  system.stateVersion = 5;

  nix.enable = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;

  programs.zsh.enable = true;

  users.users.q = {
    home = "/Users/q";
    shell = pkgs.zsh;
  };
}
