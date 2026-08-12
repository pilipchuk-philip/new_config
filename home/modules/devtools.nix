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
        typescript-language-server
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
