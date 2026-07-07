{ config, pkgs, lib, ... }:

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

  home.activation.codexStatusLine = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    codex_config="$HOME/.codex/config.toml"
    codex_status_line='status_line = ["model", "current-dir", "context-used", "context-window-size", "five-hour-limit", "weekly-limit", "used-tokens"]'

    mkdir -p "$HOME/.codex"
    if [ ! -f "$codex_config" ]; then
      printf '[tui]\n%s\n' "$codex_status_line" > "$codex_config"
      chmod 600 "$codex_config"
    elif grep -q '^\[tui\]$' "$codex_config"; then
      ${pkgs.perl}/bin/perl -0pi -e '
        my $line = q{status_line = ["model", "current-dir", "context-used", "context-window-size", "five-hour-limit", "weekly-limit", "used-tokens"]};
        s{^\[tui\]\n(?:status_line = \[.*?\]\n)?}{\[tui\]\n$line\n}ms
          or s{\z}{\n[tui]\n$line\n}ms;
      ' "$codex_config"
    else
      printf '\n[tui]\n%s\n' "$codex_status_line" >> "$codex_config"
    fi
  '';

  home.activation.zshCompletionCacheCleanup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    rm -f "$HOME"/.zcompdump "$HOME"/.zcompdump-* "$HOME"/.zcompdump*.zwc
  '';
}
