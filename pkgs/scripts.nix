{ pkgs }:

[
  (pkgs.writeShellApplication {
    name = "nix-apply";
    runtimeInputs = with pkgs; [ nix coreutils ];
    text = builtins.readFile ../scripts/nix-apply;
  })

  (pkgs.writeShellApplication {
    name = "nix-check";
    runtimeInputs = with pkgs; [ nix coreutils git ripgrep ];
    text = builtins.readFile ../scripts/nix-check;
  })

  (pkgs.writeShellApplication {
    name = "nix-clean";
    runtimeInputs = with pkgs; [ nix home-manager coreutils ];
    text = builtins.readFile ../scripts/nix-clean;
  })

  (pkgs.writeShellApplication {
    name = "nix-diff-lock";
    runtimeInputs = with pkgs; [ nix coreutils diffutils ];
    text = builtins.readFile ../scripts/nix-diff-lock;
  })

  (pkgs.writeShellApplication {
    name = "nix-rollback";
    runtimeInputs = with pkgs; [ nix home-manager coreutils ];
    text = builtins.readFile ../scripts/nix-rollback;
  })

  (pkgs.writeShellApplication {
    name = "nix-update";
    runtimeInputs = with pkgs; [ nix coreutils ];
    text = builtins.readFile ../scripts/nix-update;
  })
]
