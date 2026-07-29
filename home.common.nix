{ ... }:

{
  imports = [
    ./home/modules/shell.nix
    ./home/modules/devtools.nix
    ./home/modules/terminal.nix
    ./nixvim.nix
    # ./vscode.nix # Temporarily disabled for all hosts.
    ./tmux.nix
  ];

  home.stateVersion = "25.11";
  programs.home-manager.enable = true;

  xdg.enable = true;
}
