{ pkgs }:

[
  (pkgs.writeShellApplication {
    name = "nix-clean";
    runtimeInputs = with pkgs; [ nix home-manager coreutils ];
    text = builtins.readFile ../scripts/nix-clean.sh;
  })

  (pkgs.writeShellApplication {
    name = "nix-update";
    runtimeInputs = with pkgs; [ nix coreutils ];
    text = builtins.readFile ../scripts/nix-update.sh;
  })
]
