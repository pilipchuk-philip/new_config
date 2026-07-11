{ ... }:

{
  imports = [
    ../home.common.nix
    ./modules/toolchains.nix
  ];

  my.toolchains.enable = true;

  nixpkgs.config.allowUnfree = true;

  targets.darwin.copyApps.enable = true;
  targets.darwin.linkApps.enable = false;

}
