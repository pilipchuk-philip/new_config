{ ... }:

{
  programs.vscode.profiles.default.userSettings = {
    "telemetry.telemetryLevel" = "off";
    "search.searchEditor.defaultNumberOfContextLines" = 3;
    "editor.fontSize" = 14;
    "terminal.integrated.fontSize" = 14;
    "security.workspace.trust.untrustedFiles" = "prompt";
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
    "explorer.confirmDragAndDrop" = true;
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
    "explorer.confirmDelete" = true;
    "github.copilot.enable" = {
      "*" = true;
      plaintext = false;
      markdown = false;
      scminput = false;
    };
    "editor.formatOnSave" = true;
    "notebook.codeActionsOnSave" = {
      "notebook.source.fixAll" = "explicit";
      "notebook.source.organizeImports" = "explicit";
    };
    "nix.formatterPath" = "nixfmt";
    "[nix]"."editor.defaultFormatter" = "jnoortheen.nix-ide";
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
        before = [
          "m"
          "m"
        ];
        commands = [ "bookmarks.toggle" ];
        recursive = true;
      }
      {
        before = [
          "s"
          "v"
        ];
        commands = [ "workbench.action.splitEditor" ];
        recursive = true;
      }
      {
        before = [
          "s"
          "s"
        ];
        commands = [ "workbench.action.splitEditorUp" ];
        recursive = true;
      }
      {
        before = [
          "<leader>"
          "c"
          "p"
        ];
        commands = [ "copyRelativeFilePath" ];
      }
      {
        before = [
          "<leader>"
          "g"
          "s"
        ];
        commands = [ "git.viewChanges" ];
      }
      {
        before = [
          "<leader>"
          "l"
          "s"
        ];
        commands = [ "workbench.action.gotoSymbol" ];
      }
      {
        before = [
          "<leader>"
          "t"
        ];
        commands = [ "workbench.actions.view.problems" ];
      }
      {
        before = [
          "g"
          "r"
        ];
        commands = [ "editor.action.referenceSearch.trigger" ];
      }
      {
        before = [
          "<leader>"
          "f"
          "f"
        ];
        commands = [ "editor.action.formatDocument" ];
      }
      {
        before = [
          "<leader>"
          "c"
        ];
        commands = [ "workbench.action.chat.open" ];
      }
      {
        before = [
          "<leader>"
          "o"
          "g"
        ];
        commands = [
          {
            command = "workbench.action.terminal.sendSequence";
            args.text = "gh browse \${relativeFile}:\${lineNumber}\n";
          }
        ];
      }
    ];
  };
}
