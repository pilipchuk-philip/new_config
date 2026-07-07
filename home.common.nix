{ config, ... }:

{
  imports = [
    ./home/modules/shell.nix
    ./home/modules/devtools.nix
    ./home/modules/terminal.nix
    ./nixvim.nix
    ./vscode.nix
    ./tmux.nix
  ];

  home.stateVersion = "25.11";
  programs.home-manager.enable = true;

  xdg.enable = true;
  sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
}
