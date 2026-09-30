{ ... }:

{
  # The OpenCode installer registers this pinned plugin in both server and TUI configs.
  xdg.configFile."opencode/opencode.jsonc".text = builtins.toJSON {
    "$schema" = "https://opencode.ai/config.json";
    plugin = [ "opencode-usage-monitor@2.0.1" ];
  };

  xdg.configFile."opencode/tui.json".text = builtins.toJSON {
    plugin = [ "opencode-usage-monitor@2.0.1" ];
  };

  xdg.configFile."opencode/usage-monitor.json".text = builtins.toJSON {
    version = 2;
    providers.openai = { };
  };
}
