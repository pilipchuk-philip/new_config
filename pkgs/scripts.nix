{ pkgs }:

let
  targetDetector = pkgs.writeShellApplication {
    name = "nix-target";
    runtimeInputs = [ pkgs.coreutils ];
    text = builtins.readFile ../scripts/nix-target;
  };
  repoResolver = pkgs.writeShellApplication {
    name = "nix-repo";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.git
    ];
    text = builtins.readFile ../scripts/nix-repo;
  };
in
[
  targetDetector
  repoResolver
  (pkgs.writeShellApplication {
    name = "nix-apply";
    runtimeInputs = [
      pkgs.nix
      pkgs.coreutils
      targetDetector
      repoResolver
    ];
    text = builtins.readFile ../scripts/nix-apply;
  })

  (pkgs.writeShellApplication {
    name = "nix-check";
    runtimeInputs = builtins.attrValues {
      inherit (pkgs)
        nix
        coreutils
        git
        ripgrep
        shellcheck
        ;
    };
    text = builtins.readFile ../scripts/nix-check;
  })

  (pkgs.writeShellApplication {
    name = "nix-clean";
    runtimeInputs = [
      pkgs.nix
      pkgs.home-manager
      pkgs.coreutils
    ];
    text = builtins.readFile ../scripts/nix-clean;
  })

  (pkgs.writeShellApplication {
    name = "nix-diff-lock";
    runtimeInputs = [
      pkgs.nix
      pkgs.coreutils
      pkgs.diffutils
    ];
    text = builtins.readFile ../scripts/nix-diff-lock;
  })

  (pkgs.writeShellApplication {
    name = "nix-rollback";
    runtimeInputs = [
      pkgs.nix
      pkgs.home-manager
      pkgs.coreutils
    ];
    text = builtins.readFile ../scripts/nix-rollback;
  })

  (pkgs.writeShellApplication {
    name = "gdp";
    runtimeInputs = [
      pkgs.git
      pkgs.delta
    ];
    text = builtins.readFile ../scripts/gdp;
  })

  (pkgs.writeShellApplication {
    name = "nix-update";
    runtimeInputs = [
      pkgs.nix
      pkgs.coreutils
      targetDetector
      repoResolver
    ];
    text = builtins.readFile ../scripts/nix-update;
  })
]
