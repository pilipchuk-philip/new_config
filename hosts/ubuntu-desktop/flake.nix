{
  description = "Ubuntu desktop Home Manager host";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixvim.url = "github:nix-community/nixvim/nixos-25.11";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, nixvim, home-manager, sops-nix, ... }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in
  {
    homeConfigurations.ubuntu-desktop = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        ({ pkgs, ... }: {
          imports = [
            nixvim.homeModules.nixvim
            sops-nix.homeManagerModules.sops
            ../../home.nix
          ];
          targets.genericLinux.enable = true;
          fonts.fontconfig.enable = true;
          home.username = "q";
          home.homeDirectory = "/home/q";
          home.packages = [
            # pkgs._1password-cli
            # pkgs._1password-gui
            pkgs.codex
            pkgs.ghostty
            pkgs.nerd-fonts.jetbrains-mono
          ];
        })
      ];
    };
  };
}
