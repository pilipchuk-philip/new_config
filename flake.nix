{
  description = "Cross-platform Nix config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixvim.url = "github:nix-community/nixvim";

    nixvim.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixvim,
      home-manager,
      darwin,
      ...
    }:
    let
      linuxSystem = "x86_64-linux";
      darwinSystem = "aarch64-darwin";
      pkgs = import nixpkgs {
        system = linuxSystem;
        config.allowUnfree = true;
      };
      pkgsDarwin = import nixpkgs {
        system = darwinSystem;
        config.allowUnfree = true;
      };
      evalString = value: builtins.unsafeDiscardStringContext (toString value);
      sharedHomeSettings = {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "bak";
      };
      homeImports = homeModule: [
        nixvim.homeModules.nixvim
        ({ ... }: {
          programs.nixvim.nixpkgs = {
            source = nixpkgs;
            config = {
              allowUnfree = true;
              allowUnfreePredicate = _: true;
            };
          };
        })
        homeModule
      ];
      mkStandaloneHome =
        homeModule:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = homeImports homeModule;
        };
      mkDarwin =
        {
          hostModule,
          user,
          homeModule,
        }:
        darwin.lib.darwinSystem {
          system = darwinSystem;
          pkgs = pkgsDarwin;
          modules = [
            hostModule
            home-manager.darwinModules.home-manager
            (
              sharedHomeSettings
              // {
                home-manager.users.${user}.imports = homeImports homeModule;
              }
            )
          ];
        };
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = linuxSystem;

        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          (
            sharedHomeSettings
            // {
              home-manager.users.q.imports = homeImports ./home.nix;
            }
          )
        ];
      };

      homeConfigurations.ubuntu-desktop = mkStandaloneHome ./home/ubuntu-desktop.nix;

      darwinConfigurations.mac = mkDarwin {
        hostModule = ./darwin/personal.nix;
        user = "q";
        homeModule = ./home/darwin-personal.nix;
      };

      darwinConfigurations.mac-work = mkDarwin {
        hostModule = ./darwin/work.nix;
        user = "ppy";
        homeModule = ./home/darwin-work.nix;
      };

      apps.${linuxSystem}.home-manager = {
        type = "app";
        program = "${home-manager.packages.${linuxSystem}.home-manager}/bin/home-manager";
        meta.description = "Home Manager CLI from the locked flake input";
      };

      checks = {
        ${linuxSystem} = {
          eval-linux =
            pkgs.runCommand "eval-linux-configurations"
              {
                nixosToplevel = evalString self.nixosConfigurations.nixos.config.system.build.toplevel.drvPath;
                ubuntuActivation = evalString self.homeConfigurations.ubuntu-desktop.activationPackage.drvPath;
              }
              ''
                touch "$out"
              '';

          eval-all =
            pkgs.runCommand "eval-all-configurations"
              {
                nixosToplevel = evalString self.nixosConfigurations.nixos.config.system.build.toplevel.drvPath;
                ubuntuActivation = evalString self.homeConfigurations.ubuntu-desktop.activationPackage.drvPath;
                darwinPersonal = evalString self.darwinConfigurations.mac.system;
                darwinWork = evalString self.darwinConfigurations.mac-work.system;
              }
              ''
                touch "$out"
              '';
        };

        ${darwinSystem} = {
          eval-darwin =
            pkgsDarwin.runCommand "eval-darwin-configurations"
              {
                darwinPersonal = evalString self.darwinConfigurations.mac.system;
                darwinWork = evalString self.darwinConfigurations.mac-work.system;
              }
              ''
                touch "$out"
              '';

          eval-all =
            pkgsDarwin.runCommand "eval-all-configurations"
              {
                nixosToplevel = evalString self.nixosConfigurations.nixos.config.system.build.toplevel.drvPath;
                ubuntuActivation = evalString self.homeConfigurations.ubuntu-desktop.activationPackage.drvPath;
                darwinPersonal = evalString self.darwinConfigurations.mac.system;
                darwinWork = evalString self.darwinConfigurations.mac-work.system;
              }
              ''
                touch "$out"
              '';
        };
      };
    };
}
