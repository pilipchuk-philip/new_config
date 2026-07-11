{ pkgs, ... }:

let
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
      args = {
        text = ":";
      };
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
  imports = [
    ./extensions.nix
    ./settings.nix
  ];

  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    mutableExtensionsDir = false;

    profiles.default = {
      keybindings = if pkgs.stdenv.isDarwin then macKeybindings else linuxKeybindings;
    };
  };
}
