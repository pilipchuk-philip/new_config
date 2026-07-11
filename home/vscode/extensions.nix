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
    (with pkgs.vscode-extensions; [
      alefragnani.bookmarks
      charliermarsh.ruff
      github.copilot
      github.copilot-chat
      github.github-vscode-theme
      gruntfuggly.todo-tree
      jnoortheen.nix-ide
      ms-azuretools.vscode-containers
      ms-python.debugpy
      ms-python.python
      ms-python.vscode-pylance
      ms-toolsai.jupyter
      ms-toolsai.jupyter-keymap
      ms-toolsai.jupyter-renderers
      ms-toolsai.vscode-jupyter-cell-tags
      ms-toolsai.vscode-jupyter-slideshow
      ms-vscode-remote.remote-containers
      ms-vscode-remote.remote-ssh
      ms-vscode-remote.remote-ssh-edit
      ms-vscode.remote-explorer
      pkief.material-icon-theme
      usernamehw.errorlens
      vscodevim.vim
    ])
    ++ marketplaceExtensions;
}
