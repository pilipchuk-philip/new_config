{
  description = "Cross-platform Nix config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixvim.url = "github:nix-community/nixvim";

    nixvim.inputs.nixpkgs.follows = "nixpkgs";
    nixvim-darwin.url = "github:nix-community/nixvim";
    nixvim-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    home-manager-darwin.url = "github:nix-community/home-manager";
    home-manager-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";
    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix-darwin.url = "github:Mic92/sops-nix";
    sops-nix-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-darwin, nixvim, nixvim-darwin, home-manager, home-manager-darwin, darwin, sops-nix, sops-nix-darwin, ... }:
  let
    linuxSystem = "x86_64-linux";
    darwinSystem = "aarch64-darwin";
    pkgs = import nixpkgs {
      system = linuxSystem;
      config.allowUnfree = true;
    };
    pkgsDarwin = import nixpkgs-darwin {
      system = darwinSystem;
      config.allowUnfree = true;
    };
    evalString = value: builtins.unsafeDiscardStringContext (toString value);
    sharedHomeSettings = {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "bak";
    };
  in
  {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = linuxSystem;

      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "bak";
          home-manager.users.q.imports = [
            nixvim.homeModules.nixvim
            sops-nix.homeManagerModules.sops
            ({ ... }: {
              programs.nixvim.nixpkgs.source = nixpkgs;
            })
            ./home.nix
          ];
        }
      ];
    };

    homeConfigurations.ubuntu-desktop = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        nixvim.homeModules.nixvim
        sops-nix.homeManagerModules.sops
        ({ ... }: {
          programs.nixvim.nixpkgs.source = nixpkgs;
        })
        ./home/ubuntu-desktop.nix
      ];
    };

    darwinConfigurations.mac = darwin.lib.darwinSystem {
      system = darwinSystem;
      pkgs = pkgsDarwin;
      modules = [
        ./darwin/personal.nix
        home-manager-darwin.darwinModules.home-manager
        (sharedHomeSettings // {
          home-manager.users.q.imports = [
            nixvim-darwin.homeModules.nixvim
            sops-nix-darwin.homeManagerModules.sops
            ({ ... }: {
              programs.nixvim.nixpkgs.source = nixpkgs-darwin;
            })
            ./home/darwin-personal.nix
          ];
        })
      ];
    };

    darwinConfigurations.mac-work = darwin.lib.darwinSystem {
      system = darwinSystem;
      pkgs = pkgsDarwin;
      modules = [
        ./darwin/work.nix
        home-manager-darwin.darwinModules.home-manager
        (sharedHomeSettings // {
          home-manager.users.ppy.imports = [
            nixvim-darwin.homeModules.nixvim
            sops-nix-darwin.homeManagerModules.sops
            ({ ... }: {
              programs.nixvim.nixpkgs.source = nixpkgs-darwin;
            })
            ./home/darwin-work.nix
          ];
        })
      ];
    };

    apps.${linuxSystem}.home-manager = {
      type = "app";
      program = "${home-manager.packages.${linuxSystem}.home-manager}/bin/home-manager";
      meta.description = "Home Manager CLI from the locked flake input";
    };

    checks = {
      ${linuxSystem}.eval-configurations = pkgs.runCommand "eval-configurations" {
        nixosToplevel = evalString self.nixosConfigurations.nixos.config.system.build.toplevel.drvPath;
        ubuntuActivation = evalString self.homeConfigurations.ubuntu-desktop.activationPackage.drvPath;
        darwinPersonal = evalString self.darwinConfigurations.mac.system;
        darwinWork = evalString self.darwinConfigurations.mac-work.system;
      } ''
        touch "$out"
      '';

      ${darwinSystem}.eval-configurations = pkgsDarwin.runCommand "eval-configurations" {
        nixosToplevel = evalString self.nixosConfigurations.nixos.config.system.build.toplevel.drvPath;
        ubuntuActivation = evalString self.homeConfigurations.ubuntu-desktop.activationPackage.drvPath;
        darwinPersonal = evalString self.darwinConfigurations.mac.system;
        darwinWork = evalString self.darwinConfigurations.mac-work.system;
      } ''
        touch "$out"
      '';
    };
  };
}
