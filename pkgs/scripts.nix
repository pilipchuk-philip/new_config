{ pkgs }:

let
  targetDetector = pkgs.writeShellApplication {
    name = "nix-target";
    runtimeInputs = with pkgs; [ coreutils ];
    text = builtins.readFile ../scripts/nix-target;
  };
  repoResolver = pkgs.writeShellApplication {
    name = "nix-repo";
    runtimeInputs = with pkgs; [
      coreutils
      git
    ];
    text = builtins.readFile ../scripts/nix-repo;
  };
in
[
  targetDetector
  repoResolver
  (pkgs.writeShellApplication {
    name = "nix-apply";
    runtimeInputs = with pkgs; [
      nix
      coreutils
      targetDetector
      repoResolver
    ];
    text = builtins.readFile ../scripts/nix-apply;
  })

  (pkgs.writeShellApplication {
    name = "nix-check";
    runtimeInputs = with pkgs; [
      nix
      coreutils
      git
      ripgrep
      shellcheck
    ];
    text = builtins.readFile ../scripts/nix-check;
  })

  (pkgs.writeShellApplication {
    name = "nix-clean";
    runtimeInputs = with pkgs; [
      nix
      home-manager
      coreutils
    ];
    text = builtins.readFile ../scripts/nix-clean;
  })

  (pkgs.writeShellApplication {
    name = "nix-diff-lock";
    runtimeInputs = with pkgs; [
      nix
      coreutils
      diffutils
    ];
    text = builtins.readFile ../scripts/nix-diff-lock;
  })

  (pkgs.writeShellApplication {
    name = "nix-rollback";
    runtimeInputs = with pkgs; [
      nix
      home-manager
      coreutils
    ];
    text = builtins.readFile ../scripts/nix-rollback;
  })

  (pkgs.writeShellApplication {
    name = "nix-update";
    runtimeInputs = with pkgs; [
      nix
      coreutils
      targetDetector
      repoResolver
    ];
    text = builtins.readFile ../scripts/nix-update;
  })
]
