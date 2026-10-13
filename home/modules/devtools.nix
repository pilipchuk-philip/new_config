{
  config,
  pkgs,
  lib,
  ...
}:

let
  localScripts = import ../../pkgs/scripts.nix { inherit pkgs; };
  catppuccinDelta = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/catppuccin/delta/main/catppuccin.gitconfig";
    sha256 = "0mdlccyzjzlidiwilbd1fi233v5bmfi1cldj32vnfdqydgd0ln7h";
  };
in
{
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    package =
      if pkgs.stdenv.isDarwin then
        pkgs.direnv.overrideAttrs (_: {
          doCheck = false;
        })
      else
        pkgs.direnv;
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
    lib.optionals pkgs.stdenv.isLinux [
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
        marksman

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
        opencode
        ;
    })
    ++ [
      (if pkgs.stdenv.hostPlatform.isDarwin then
        pkgs.typescript-language-server.overrideAttrs (old: {
          # nixpkgs 7fd4004: pnpm deps for 6.0.2 have an outdated hash on macOS.
          pnpmDeps = old.pnpmDeps.overrideAttrs (_: {
            outputHash = "sha256-PmyJb8090pEPc09Tbv8RgdvQpzpba2L8ve87+aVncQU=";
          });
        })
      else
        pkgs.typescript-language-server)
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
