{
  description = "NixOS 25.11 + Home Manager 25.11 (user: q)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixvim.url = "github:nix-community/nixvim/nixos-25.11";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    darwin.url = "github:LnL7/nix-darwin/nix-darwin-25.11";
    darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixpkgs-darwin, nixpkgs-unstable, nixvim, home-manager, darwin, sops-nix, ... }:
  let
    linuxSystem = "x86_64-linux";
    darwinSystem = "aarch64-darwin";
    pkgs-unstable = import nixpkgs-unstable { system = linuxSystem; };
  in
  {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = linuxSystem;

      modules = [
        ./configuration.nix
        ({ ... }: {
           nixpkgs.overlays = [
             (final: prev: {
               tree-sitter = pkgs-unstable.tree-sitter;
             })
           ];
        })

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
	  home-manager.backupFileExtension = "bak";
          home-manager.sharedModules = [ nixvim.homeModules.nixvim sops-nix.homeManagerModules.sops ];
          home-manager.users.q = import ./home.nix;
        }
      ];
    };

    darwinConfigurations.mac = darwin.lib.darwinSystem {
      system = darwinSystem;
      pkgs = import nixpkgs-darwin {
        system = darwinSystem;
        config.allowUnfree = true;
      };
      modules = [
        ./darwin.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "bak";
          home-manager.sharedModules = [ nixvim.homeModules.nixvim sops-nix.homeManagerModules.sops ];
          home-manager.users.q = import ./home.darwin.nix;
        }
      ];
    };
  };
}
