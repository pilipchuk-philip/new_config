{
  config,
  lib,
  pkgs,
  ...
}:

let
  tectonic = pkgs.tectonic;
  # Keep the previous workaround for rollback; use the binary cache by default.
  # tectonic 0.17.0 is missing AWS-LC in its build inputs.
  # tectonic =
  #   if pkgs.tectonic-unwrapped.version == "0.17.0" then
  #     pkgs.tectonic.override {
  #       tectonic-unwrapped = pkgs.tectonic-unwrapped.overrideAttrs (old: {
  #         buildInputs = (old.buildInputs or [ ]) ++ [ pkgs.aws-lc ];
  #       });
  #     }
  #   else
  #     pkgs.tectonic;
in
{
  options.my.toolchains.enable = lib.mkEnableOption "shared global development toolchains";

  # Global toolchains used by the shared editor setup. Project-specific versions
  # should still be pinned in each project's devShell.
  config.home.packages = lib.mkIf config.my.toolchains.enable (
    (builtins.attrValues {
      inherit (pkgs)
        gcc
        gnumake
        nodejs
        python313
        go
        rustc
        cargo
        jdt-language-server
        terraform-ls
        ;
    })
    ++ [ tectonic ]
  );
}
