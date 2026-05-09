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
  linuxKeybindings = [
    {
      key = "ctrl+shift+c";
      command = "github.copilot.completions.toggle";
    }
    {
      key = "ctrl+l";
      command = "workbench.action.navigateRight";
    }
    {
      key = "ctrl+h";
      command = "workbench.action.navigateLeft";
    }
    {
      key = "ctrl+j";
      command = "workbench.action.navigateDown";
    }
    {
      key = "ctrl+k";
      command = "workbench.action.navigateUp";
    }
    {
      key = "tab";
      command = "workbench.action.nextEditorInGroup";
      when = "(vim.mode == 'Normal' || vim.mode == 'Visual') && (editorTextFocus || !inputFocus)";
    }
    {
      key = "shift+tab";
      command = "workbench.action.previousEditorInGroup";
      when = "(vim.mode == 'Normal' || vim.mode == 'Visual') && (editorTextFocus || !inputFocus)";
    }
    {
      key = "alt+p";
      command = "workbench.action.quickOpen";
    }
    {
      key = "ctrl+p";
      command = "workbench.action.quickOpen";
    }
    {
      key = "alt+w";
      command = "workbench.action.closeActiveEditor";
    }
    {
      key = "shift+alt+w";
      command = "workbench.action.closeAllGroups";
    }
    {
      key = "alt+e";
      command = "workbench.action.showAllEditors";
      when = "vim.mode == 'Normal' && (editorTextFocus || !inputFocus)";
    }
    {
      key = "ctrl+e";
      command = "workbench.action.showAllEditors";
      when = "vim.mode == 'Normal' && (editorTextFocus || !inputFocus)";
    }
    {
      key = ";";
      when = "vim.mode == 'Normal'";
      command = "type";
      args = { text = ":"; };
    }
    {
      key = "alt+t";
      command = "workbench.action.terminal.toggleTerminal";
    }
    {
      key = "ctrl+t";
      command = "workbench.action.terminal.toggleTerminal";
    }
    {
      key = "ctrl+shift+f";
      command = "filesExplorer.findInFolder";
      when = "filesExplorerFocus";
    }
    {
      key = "/";
      command = "actions.find";
      when = "vim.mode == 'Normal' && editorFocus";
    }
    {
      key = "alt+1";
      command = "runCommands";
      args = {
        commands = [
          "workbench.action.toggleSidebarVisibility"
          "workbench.files.action.focusFilesExplorer"
        ];
      };
    }
    {
      key = "alt+1";
      command = "workbench.action.toggleSidebarVisibility";
      when = "sideBarVisible";
    }
    {
      key = "alt+2";
      command = "runCommands";
      args = {
        commands = [
          "workbench.action.toggleSidebarVisibility"
          "workbench.view.scm"
        ];
      };
    }
    {
      key = "alt+3";
      command = "runCommands";
      args = {
        commands = [
          "workbench.action.toggleSidebarVisibility"
          "workbench.view.extension.bookmarks"
        ];
      };
    }
    {
      key = "alt+3";
      command = "workbench.action.toggleSidebarVisibility";
      when = "sideBarVisible && activeViewlet == 'workbench.view.extension.bookmarks'";
    }
    {
      key = "shift+k";
      command = "editor.action.moveLinesUpAction";
      when = "vim.mode == 'VisualLine' && editorTextFocus";
    }
    {
      key = "shift+k";
      command = "editor.action.showHover";
      when = "vim.mode == 'Normal' && editorTextFocus";
    }
    {
      key = "alt+enter";
      command = "editor.action.codeAction";
      when = "vim.mode == 'Normal' && editorTextFocus";
    }
    {
      key = "alt+r";
      command = "editor.action.goToReferences";
      when = "editorTextFocus && vim.active && vim.mode == 'Normal'";
    }
    {
      key = "r";
      command = "renameFile";
      when = "filesExplorerFocus && foldersViewVisible && !explorerResourceIsRoot && !explorerResourceReadonly && !inputFocus";
    }
    {
      key = "c";
      command = "filesExplorer.copy";
      when = "filesExplorerFocus && foldersViewVisible && !explorerResourceIsRoot && !explorerResourceReadonly && !inputFocus";
    }
    {
      key = "p";
      command = "filesExplorer.paste";
      when = "filesExplorerFocus && foldersViewVisible && !explorerResourceIsRoot && !explorerResourceReadonly && !inputFocus";
    }
    {
      key = "x";
      command = "filesExplorer.cut";
      when = "filesExplorerFocus && foldersViewVisible && !explorerResourceIsRoot && !explorerResourceReadonly && !inputFocus";
    }
    {
      key = "d";
      command = "deleteFile";
      when = "filesExplorerFocus && foldersViewVisible && !explorerResourceIsRoot && !explorerResourceReadonly && !inputFocus";
    }
    {
      key = "a";
      command = "explorer.newFile";
      when = "filesExplorerFocus && foldersViewVisible && !explorerResourceIsRoot && !explorerResourceReadonly && !inputFocus";
    }
    {
      key = "shift+a";
      command = "explorer.newFolder";
      when = "filesExplorerFocus && foldersViewVisible && !explorerResourceIsRoot && !explorerResourceReadonly && !inputFocus";
    }
    {
      key = "s";
      command = "explorer.openToSide";
      when = "filesExplorerFocus && foldersViewVisible && !explorerResourceIsRoot && !explorerResourceReadonly && !inputFocus";
    }
    {
      key = "shift+s";
      command = "runCommands";
      when = "filesExplorerFocus && foldersViewVisible && !explorerResourceIsRoot && !explorerResourceReadonly && !inputFocus";
      args = {
        commands = [
          "workbench.action.splitEditorDown"
          "explorer.openAndPassFocus"
          "workbench.action.closeOtherEditors"
        ];
      };
    }
    {
      key = "enter";
      command = "explorer.openAndPassFocus";
      when = "filesExplorerFocus && foldersViewVisible && !explorerResourceIsRoot && !explorerResourceIsFolder && !inputFocus";
    }
    {
      key = "enter";
      command = "list.toggleExpand";
      when = "filesExplorerFocus && foldersViewVisible && !explorerResourceIsRoot && explorerResourceIsFolder && !inputFocus";
    }
    {
      key = "ctrl+c";
      command = "-extension.vim_ctrl+c";
      when = "editorTextFocus && vim.active && vim.overrideCtrlC && vim.use<C-c> && !inDebugRepl";
    }
    {
      key = "alt+c";
      command = "-extension.vim_ctrl+c";
      when = "editorTextFocus && vim.active && vim.overrideCtrlC && vim.use<C-c> && !inDebugRepl";
    }
    {
      key = "shift+alt+=";
      command = "-workbench.action.zoomIn";
    }
    {
      key = "alt+shift+=";
      command = "editor.foldAll";
      when = "editorTextFocus && vim.active && vim.mode == 'Normal'";
    }
    {
      key = "shift+alt+-";
      command = "editor.unfoldAll";
      when = "editorTextFocus && vim.active && vim.mode == 'Normal'";
    }
    {
      key = "shift+alt+-";
      command = "-workbench.action.zoomOut";
    }
    {
      key = "ctrl+a";
      command = "-extension.vim_ctrl+a";
      when = "editorTextFocus && vim.active && vim.use<C-a> && !inDebugRepl";
    }
    {
      key = "ctrl+a";
      command = "-list.selectAll";
      when = "listFocus && listSupportsMultiselect && !inputFocus && !treestickyScrollFocused";
    }
    {
      key = "ctrl+shift+v";
      command = "editor.action.clipboardPasteAction";
    }
    {
      key = "ctrl+v";
      command = "-editor.action.clipboardPasteAction";
    }
    {
      key = "ctrl+f";
      command = "-extension.vim_ctrl+f";
      when = "editorTextFocus && vim.active && vim.use<C-f> && !inDebugRepl && vim.mode != 'Insert'";
    }
    {
      key = "ctrl+r";
      command = "-extension.vim_ctrl+r";
      when = "editorTextFocus && vim.active && vim.use<C-r> && !inDebugRepl";
    }
    {
      key = "ctrl+alt+right";
      command = "-cursorWordPartRight";
      when = "textInputFocus";
    }
    {
      key = "ctrl+alt+right";
      command = "-quickInput.acceptInBackground";
      when = "cursorAtEndOfQuickInputBox && inQuickInput && quickInputType == 'quickPick' || inQuickInput && !inputFocus && quickInputType == 'quickPick'";
    }
    {
      key = "ctrl+alt+left";
      command = "-cursorWordPartLeft";
      when = "textInputFocus";
    }
  ];
  macKeybindings = [
    {
      key = "cmd+p";
      command = "workbench.action.quickOpen";
    }
    {
      key = "cmd+e";
      command = "workbench.action.showAllEditors";
      when = "vim.mode == 'Normal' && (editorTextFocus || !inputFocus)";
    }
    {
      key = "cmd+t";
      command = "workbench.action.terminal.toggleTerminal";
    }
    {
      key = "cmd+1";
      command = "runCommands";
      args = {
        commands = [
          "workbench.action.toggleSidebarVisibility"
          "workbench.files.action.focusFilesExplorer"
        ];
      };
    }
    {
      key = "cmd+1";
      command = "workbench.action.toggleSidebarVisibility";
      when = "sideBarVisible";
    }
    {
      key = "cmd+2";
      command = "runCommands";
      args = {
        commands = [
          "workbench.action.toggleSidebarVisibility"
          "workbench.view.scm"
        ];
      };
    }
    {
      key = "cmd+3";
      command = "runCommands";
      args = {
        commands = [
          "workbench.action.toggleSidebarVisibility"
          "workbench.view.extension.bookmarks"
        ];
      };
    }
    {
      key = "cmd+enter";
      command = "editor.action.codeAction";
      when = "vim.mode == 'Normal' && editorTextFocus";
    }
    {
      key = "cmd+r";
      command = "editor.action.goToReferences";
      when = "editorTextFocus && vim.active && vim.mode == 'Normal'";
    }
    {
      key = "cmd+c";
      command = "-extension.vim_ctrl+c";
      when = "editorTextFocus && vim.active && vim.overrideCtrlC && vim.use<C-c> && !inDebugRepl";
    }
    {
      key = "shift+cmd+=";
      command = "-workbench.action.zoomIn";
    }
    {
      key = "cmd+shift+=";
      command = "editor.foldAll";
      when = "editorTextFocus && vim.active && vim.mode == 'Normal'";
    }
    {
      key = "shift+cmd+-";
      command = "editor.unfoldAll";
      when = "editorTextFocus && vim.active && vim.mode == 'Normal'";
    }
    {
      key = "shift+cmd+-";
      command = "-workbench.action.zoomOut";
    }
  ];
in
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    mutableExtensionsDir = false;

    profiles.default = {
      extensions =
        (with pkgs.vscode-extensions; [
          alefragnani.bookmarks
          charliermarsh.ruff
          github.copilot
          github.copilot-chat
          github.github-vscode-theme
          gruntfuggly.todo-tree
          github.github-vscode-theme
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

      userSettings = {
      "telemetry.telemetryLevel" = "off";
      "search.searchEditor.defaultNumberOfContextLines" = 3;
      "editor.fontSize" = 14;
      "terminal.integrated.fontSize" = 14;
      "security.workspace.trust.untrustedFiles" = "open";
      "editor.wordWrap" = "off";
      "terminal.integrated.inheritEnv" = false;
      "terminal.integrated.shellIntegration.enabled" = true;
      "terminal.integrated.fontFamily" = "JetbrainsMono Nerd Font, Regular";
      "editor.fontFamily" = "JetbrainsMono Nerd Font, Regular";
      "editor.minimap.enabled" = false;
      "editor.unicodeHighlight.nonBasicASCII" = false;
      "editor.scrollbar.horizontal" = "hidden";
      "editor.scrollbar.vertical" = "hidden";
      "editor.lineNumbers" = "relative";
      "workbench.tree.indent" = 10;
      "editor.cursorSmoothCaretAnimation" = "on";
      "window.density.editorTabHeight" = "default";
      "editor.fontLigatures" = true;
      "workbench.tree.renderIndentGuides" = "always";
      "debug.toolBarLocation" = "commandCenter";
      "files.trimTrailingWhitespace" = true;
      "editor.formatOnPaste" = true;
      "workbench.colorTheme" = "GitHub Dark Dimmed";
      "explorer.confirmDragAndDrop" = false;
      "terminal.integrated.gpuAcceleration" = "off";
      "workbench.activityBar.location" = "top";
      "window.customTitleBarVisibility" = "auto";
      "window.titleBarStyle" = "custom";
      "vim.leader" = "<space>";
      "window.commandCenter" = true;
      "workbench.layoutControl.enabled" = false;
      "workbench.editor.pinnedTabSizing" = "compact";
      "workbench.editorAssociations" = {
        "*.db" = "default";
      };
      "explorer.fileNesting.patterns" = {
        "*.ts" = "\${capture}.js";
        "*.js" = "\${capture}.js.map, \${capture}.min.js, \${capture}.d.ts";
        "*.jsx" = "\${capture}.js";
        "*.tsx" = "\${capture}.ts";
        "tsconfig.json" = "tsconfig.*.json";
        "package.json" = "package-lock.json, yarn.lock, pnpm-lock.yaml, bun.lockb, bun.lock";
        "*.sqlite" = "\${capture}.\${extname}-*";
        "*.db" = "\${capture}.\${extname}-*";
        "*.sqlite3" = "\${capture}.\${extname}-*";
        "*.db3" = "\${capture}.\${extname}-*";
        "*.sdb" = "\${capture}.\${extname}-*";
        "*.s3db" = "\${capture}.\${extname}-*";
      };
      "explorer.confirmDelete" = false;
      "github.copilot.enable" = {
        "*" = true;
        "plaintext" = false;
        "markdown" = false;
        "scminput" = false;
      };
      "editor.formatOnSave" = true;
      "notebook.codeActionsOnSave" = {
        "notebook.source.fixAll" = "explicit";
        "notebook.source.organizeImports" = "explicit";
      };
      "nix.formatterPath" = "nixfmt";
      "[nix]" = {
        "editor.defaultFormatter" = "jnoortheen.nix-ide";
      };
      "[python]" = {
        "editor.codeActionsOnSave" = {
          "source.fixAll" = "explicit";
          "source.organizeImports" = "explicit";
        };
        "editor.defaultFormatter" = "charliermarsh.ruff";
      };
      "workbench.iconTheme" = "material-icon-theme";
      "containers.containerClient" = "com.microsoft.visualstudio.containers.docker";
      "containers.orchestratorClient" = "com.microsoft.visualstudio.orchestrators.dockercompose";
      "vim.normalModeKeyBindings" = [
        {
          before = [ "m" "m" ];
          commands = [ "bookmarks.toggle" ];
          recursive = true;
        }
        {
          before = [ "s" "v" ];
          commands = [ "workbench.action.splitEditor" ];
          recursive = true;
        }
        {
          before = [ "s" "s" ];
          commands = [ "workbench.action.splitEditorUp" ];
          recursive = true;
        }
        {
          before = [ "-" ];
          commands = [ { command = "oil-code.open"; } ];
        }
        {
          before = [ "<cr>" ];
          commands = [ { command = "oil-code.select"; } ];
        }
        {
          before = [ "<c-l>" ];
          commands = [ { command = "oil-code.refresh"; } ];
        }
        {
          before = [ "`" ];
          commands = [ { command = "oil-code.cd"; } ];
        }
        {
          before = [ "<leader>" "c" "p" ];
          commands = [ "copyRelativeFilePath" ];
        }
        {
          before = [ "<leader>" "g" "s" ];
          commands = [ "git.viewChanges" ];
        }
        {
          before = [ "<leader>" "l" "s" ];
          commands = [ "workbench.action.gotoSymbol" ];
        }
        {
          before = [ "<leader>" "g" "l" ];
          commands = [ "git-graph.view" ];
        }
        {
          before = [ "<leader>" "t" ];
          commands = [ "workbench.actions.view.problems" ];
        }
        {
          before = [ "g" "r" ];
          commands = [ "editor.action.referenceSearch.trigger" ];
        }
        {
          before = [ "<leader>" "f" "f" ];
          commands = [ "editor.action.formatDocument" ];
        }
        {
          before = [ "<leader>" "c" ];
          commands = [ "workbench.action.chat.open" ];
        }
        {
          before = [ "<leader>" "o" "g" ];
          commands = [
            {
              command = "workbench.action.terminal.sendSequence";
              args = { text = "gh browse \${relativeFile}:\${lineNumber}\n"; };
            }
          ];
        }
      ];
      };

      keybindings = linuxKeybindings;
    };
  };
}
