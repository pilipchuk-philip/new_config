{ pkgs, ... }:

{
  imports = [ ./home.common.nix ];

  targets.darwin.copyApps.enable = true;
  targets.darwin.linkApps.enable = false;
}
