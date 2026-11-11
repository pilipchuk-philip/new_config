{
  config,
  pkgs,
  lib,
  ...
}:

let
  localScripts = import ../../pkgs/scripts.nix { inherit pkgs; };
  # Use the upstream self-contained macOS release instead of bootstrapping .NET.
  # Version and hash are pinned together; Linux keeps the nixpkgs package.
  marksman =
    if pkgs.stdenv.hostPlatform.isDarwin then
      pkgs.stdenvNoCC.mkDerivation {
        pname = "marksman-bin";
        version = "2026-02-08";
        src = pkgs.fetchurl {
          url = "https://github.com/artempyanykh/marksman/releases/download/2026-02-08/marksman-macos";
          hash = "sha256-aoAcF7WsDbppeHxSgrOzvUFuZsliU/rgmNMRxrvRgzs=";
        };
        dontUnpack = true;
        # Preserve the upstream Mach-O binary and its signature.
        dontFixup = true;
        installPhase = ''
          runHook preInstall
          install -Dm755 "$src" "$out/bin/marksman"
          runHook postInstall
        '';
        doInstallCheck = true;
        installCheckPhase = ''
          runHook preInstallCheck
          "$out/bin/marksman" --version
          runHook postInstallCheck
        '';
        meta = {
          description = "Markdown language server (upstream macOS binary)";
          homepage = "https://github.com/artempyanykh/marksman";
          license = lib.licenses.mit;
          platforms = lib.platforms.darwin;
          mainProgram = "marksman";
        };
      }
    else
      pkgs.marksman;
  catppuccinDelta = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/catppuccin/delta/main/catppuccin.gitconfig";
    sha256 = "0mdlccyzjzlidiwilbd1fi233v5bmfi1cldj32vnfdqydgd0ln7h";
  };
in
{
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    package = pkgs.direnv;
    # Keep the previous workaround for rollback; use the binary cache by default.
    # package =
    #   if pkgs.stdenv.hostPlatform.isDarwin then
    #     pkgs.direnv.overrideAttrs (_: {
    #       doCheck = false;
    #     })
    #   else
    #     pkgs.direnv;
  };

  programs.git = {
    enable = true;
    includes = [ { path = "${catppuccinDelta}"; } ];
    settings = {
      alias = {
        lg = "log --graph --decorate --pretty=format:'%C(auto)%h %C(bold blue)%an%Creset %C(auto)%d %s'";
        gs = "status";
      };
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = false;
    options = {
      features = "catppuccin-mocha";
      side-by-side = true;
    };
  };

  home.packages =
    lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      pkgs.cifs-utils
    ]
    ++ (builtins.attrValues {
      inherit (pkgs)
        git
        ripgrep
        fd
        lsd
        unzip
        wget
        zip
        tmux
        btop
        fzf
        lazygit
        age
        sops
        luajit
        rsync
        tree-sitter
        uv

        # LSP servers
        lua-language-server
        pyright
        bash-language-server
        vscode-langservers-extracted
        yaml-language-server
        dockerfile-language-server
        nil
        sqls

        # format-on-save tools
        nixfmt
        ruff
        prettier
        shfmt
        goimports-reviser
        vale
        mypy
        imagemagick
        ghostscript
        mermaid-cli
        gh
        lynx
        nchat
        opencode
        ;
    })
    ++ [
      marksman
      pkgs.typescript-language-server
      pkgs.llvmPackages.clang-tools
      pkgs.valeStyles.proselint
    ]
    ++ localScripts;

  xdg.configFile."vale/styles".source = pkgs.valeStyles.proselint;

  home.file.".vale.ini".text = ''
    StylesPath = ${config.xdg.configHome}/vale/styles
    MinAlertLevel = suggestion

    [*.md]
    BasedOnStyles = proselint
  '';
}
