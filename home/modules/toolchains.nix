{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.my.toolchains.enable = lib.mkEnableOption "shared global development toolchains";

  # Global toolchains used by the shared editor setup. Project-specific versions
  # should still be pinned in each project's devShell.
  config.home.packages = lib.mkIf config.my.toolchains.enable (
    with pkgs;
    [
      gcc
      gnumake
      nodejs
      python313
      go
      rustc
      cargo
      jdt-language-server
      terraform-ls
      tectonic
    ]
  );
}
