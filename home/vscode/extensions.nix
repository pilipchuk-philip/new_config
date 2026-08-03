{ pkgs, ... }:

let
  marketplaceExtensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    {
      publisher = "OpenAI";
      name = "chatgpt";
      version = "26.5513.21555";
      sha256 = "0hs4vn77wd9x7ic00s673ixaw4i1bs8wlr68nlnv60yhm3l80lgr";
    }
    {
      publisher = "igorsbitnev";
      name = "error-gutters";
      version = "1.0.1";
      sha256 = "1pdi0mcwwk7bir9zvsqfbw3jkvyfg5s1xzd805m26dlz7psv9yj3";
    }
    {
      publisher = "kevinrose";
      name = "vsc-python-indent";
      version = "1.21.0";
      sha256 = "1zlkbxgl8bad8g1lm60z0zf5gr1011p696zps3azr89cdxa63wja";
    }
    {
      publisher = "ms-python";
      name = "vscode-python-envs";
      version = "1.16.0";
      sha256 = "0dz89sjwj4ldknm5q5av9zvgpy4m4d7mjj9dnvml3ydpxscwampk";
    }
    {
      publisher = "wayou";
      name = "vscode-todo-highlight";
      version = "1.0.5";
      sha256 = "1sg4zbr1jgj9adsj3rik5flcn6cbr4k2pzxi446rfzbzvcqns189";
    }
  ];
in
{
  programs.vscode.profiles.default.extensions =
    [
      pkgs.vscode-extensions.alefragnani.bookmarks
      pkgs.vscode-extensions.charliermarsh.ruff
      pkgs.vscode-extensions.github.copilot
      pkgs.vscode-extensions.github.copilot-chat
      pkgs.vscode-extensions.github.github-vscode-theme
      pkgs.vscode-extensions.gruntfuggly.todo-tree
      pkgs.vscode-extensions.jnoortheen.nix-ide
      pkgs.vscode-extensions.ms-azuretools.vscode-containers
      pkgs.vscode-extensions.ms-python.debugpy
      pkgs.vscode-extensions.ms-python.python
      pkgs.vscode-extensions.ms-python.vscode-pylance
      pkgs.vscode-extensions.ms-toolsai.jupyter
      pkgs.vscode-extensions.ms-toolsai.jupyter-keymap
      pkgs.vscode-extensions.ms-toolsai.jupyter-renderers
      pkgs.vscode-extensions.ms-toolsai.vscode-jupyter-cell-tags
      pkgs.vscode-extensions.ms-toolsai.vscode-jupyter-slideshow
      pkgs.vscode-extensions.ms-vscode-remote.remote-containers
      pkgs.vscode-extensions.ms-vscode-remote.remote-ssh
      pkgs.vscode-extensions.ms-vscode-remote.remote-ssh-edit
      pkgs.vscode-extensions.ms-vscode.remote-explorer
      pkgs.vscode-extensions.pkief.material-icon-theme
      pkgs.vscode-extensions.usernamehw.errorlens
      pkgs.vscode-extensions.vscodevim.vim
    ]
    ++ marketplaceExtensions;
}
