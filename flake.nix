{
  description = "NixOS 25.11 + Home Manager 25.11 (user: q)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixvim.url = "github:nix-community/nixvim/nixos-25.11";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nixvim, home-manager, ... }:
  let
    system = "x86_64-linux";
    pkgs-unstable = import nixpkgs-unstable { inherit system; };
  in
  {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;

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
          home-manager.sharedModules = [ nixvim.homeModules.nixvim ];
          home-manager.users.q = import ./home.nix;
        }
      ];
    };
  };
}
