{ ... }:

{
  # The OpenCode installer registers this pinned plugin in both server and TUI configs.
  # OpenCode's installer may have already created these files before Home Manager takes ownership.
  xdg.configFile."opencode/opencode.jsonc" = {
    force = true;
    text = builtins.toJSON {
      "$schema" = "https://opencode.ai/config.json";
      plugin = [ "opencode-usage-monitor@2.0.1" ];
    };
  };

  xdg.configFile."opencode/tui.json" = {
    force = true;
    text = builtins.toJSON {
      plugin = [ "opencode-usage-monitor@2.0.1" ];
    };
  };

  xdg.configFile."opencode/usage-monitor.json" = {
    force = true;
    text = builtins.toJSON {
      version = 2;
      providers.openai = { };
    };
  };

  # Keep skill content separate while installing it globally for OpenCode.
  xdg.configFile."opencode/skills/nix/SKILL.md".source = ./skills/nix.md;
  xdg.configFile."opencode/skills/home-dev/SKILL.md".source = ./skills/home-dev.md;
  xdg.configFile."opencode/skills/reliable-development/SKILL.md".source = ./skills/reliable-development.md;
}
