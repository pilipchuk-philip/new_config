{ pkgs, ... }:

let
  mattPocockSkills = pkgs.fetchFromGitHub {
    owner = "mattpocock";
    repo = "skills";
    rev = "f3fc5632f401156837ee3872f14fe33ccf1024ea";
    hash = "sha256-rDTDP9smBDjVOloz61ZqWIMEn9sME5V4ulde1c79MaY=";
  };
in
{
  xdg.configFile."opencode/skills/grill-me".source =
    "${mattPocockSkills}/skills/productivity/grill-me";
  # Upstream grill-me delegates the interview to this skill.
  xdg.configFile."opencode/skills/grilling".source =
    "${mattPocockSkills}/skills/productivity/grilling";

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
  xdg.configFile."opencode/skills/real-dev/SKILL.md".source = ./skills/real-dev.md;
}
