{
  description = "macOS host flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    nixvim.url = "github:nix-community/nixvim/nixos-25.11";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:LnL7/nix-darwin/nix-darwin-25.11";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, nixvim, home-manager, darwin, sops-nix, ... }:
  let
    system = "aarch64-darwin";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    sharedHomeSettings = {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "bak";
    };
  in
  {
    darwinConfigurations.mac = darwin.lib.darwinSystem {
      inherit system pkgs;
      modules = [
        ../../darwin/personal.nix
        home-manager.darwinModules.home-manager
        (sharedHomeSettings // {
          home-manager.users.q.imports = [
            nixvim.homeModules.nixvim
            sops-nix.homeManagerModules.sops
            ../../home/darwin-personal.nix
          ];
        })
      ];
    };

    darwinConfigurations.mac-work = darwin.lib.darwinSystem {
      inherit system pkgs;
      modules = [
        ../../darwin/work.nix
        home-manager.darwinModules.home-manager
        (sharedHomeSettings // {
          home-manager.users.ppy.imports = [
            nixvim.homeModules.nixvim
            sops-nix.homeManagerModules.sops
            ../../home/darwin-work.nix
          ];
        })
      ];
    };
  };
}
