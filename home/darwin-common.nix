{ ... }:

{
  imports = [ ../home.common.nix ];

  nixpkgs.config.allowUnfree = true;

  targets.darwin.copyApps.enable = true;
  targets.darwin.linkApps.enable = false;

  programs.zsh.initContent = ''
    export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"
  '';
}
