{ config, lib, pkgs, ... }:

let
  usageMonitor = "opencode-usage-monitor@latest";
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

  # Follow npm's latest tag; activation refreshes already cached plugin packages.
  # OpenCode's installer may have already created these files before Home Manager takes ownership.
  xdg.configFile."opencode/opencode.jsonc" = {
    force = true;
    text = builtins.toJSON {
      "$schema" = "https://opencode.ai/config.json";
      plugins = [
        usageMonitor
        "@tarquinen/opencode-dcp@3.2.0"
      ];
      mcp.context7 = {
        type = "remote";
        url = "https://mcp.context7.com/mcp";
      };
      provider.lmstudio = {
        npm = "@ai-sdk/openai-compatible";
        name = "LM Studio (local)";
        options = {
          baseURL = "http://127.0.0.1:1234/v1";
          # Ubuntu provides this secret through sops-nix, including for GUI launches.
          apiKey =
            if config ? sops && config.sops.secrets ? LM_API_TOKEN then
              "{file:${config.sops.secrets.LM_API_TOKEN.path}}"
            else
              "{env:LM_API_TOKEN}";
        };
        # IDs returned by LM Studio's /v1/models; embeddings are not chat models.
        models = {
          "deepseek/deepseek-r1-0528-qwen3-8b".name = "DeepSeek R1 0528 Qwen3 8B (local)";
          "qwen/qwen3-4b-2507".name = "Qwen3 4B 2507 (local)";
          "nvidia/nemotron-3-nano-4b".name = "Nemotron 3 Nano 4B (local)";
          "qwen/qwen3-4b".name = "Qwen3 4B (local)";
          "qwen/qwen3-4b-thinking-2507".name = "Qwen3 4B Thinking 2507 (local)";
          "qwen/qwen3-vl-4b".name = "Qwen3 VL 4B (local)";
          "openai/gpt-oss-20b".name = "GPT OSS 20B (local)";
          "meta/muse-glimmer".name = "Muse Glimmer (local)";
          "mistralai/ministral-3-14b-reasoning".name = "Ministral 3 14B Reasoning (local)";
          "google/gemma-4-26b-a4b".name = "Gemma 4 26B A4B (local)";
          "google/gemma-4-12b".name = "Gemma 4 12B (local)";
          "google/gemma-4-e4b".name = "Gemma 4 E4B (local)";
        };
      };
    };
  };

  xdg.configFile."opencode/cli.json" = {
    force = true;
    text = builtins.toJSON {
      "$schema" = "https://opencode.ai/v2/cli.json";
      plugins = [ usageMonitor ];
    };
  };

  # Unpinned plugins are checked, but not upgraded, on OpenCode startup.
  # Bootstrap the cache first: update cannot check a target that is not installed.
  # Both configs already contain the target, so add does not rewrite their links.
  # Run after config links are installed; respect Home Manager's dry-run mode.
  home.activation.updateOpencodeUsageMonitor = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    if run ${lib.getExe pkgs.opencode} plugin add ${lib.escapeShellArg usageMonitor} &&
       run ${lib.getExe pkgs.opencode} plugin update ${lib.escapeShellArg usageMonitor}; then
      :
    else
      echo "Warning: opencode-usage-monitor install/update failed; retry with: opencode plugin add ${usageMonitor} && opencode plugin update ${usageMonitor}" >&2
    fi
  '';

  xdg.configFile."opencode/usage-monitor.json" = {
    force = true;
    text = builtins.toJSON {
      version = 2;
      providers.openai = { };
    };
  };

  # Keep skill content separate while installing it globally for OpenCode.
  xdg.configFile."opencode/skills/nix/SKILL.md".source = ./skills/nix.md;
  xdg.configFile."opencode/skills/homelab-services/SKILL.md".source = ./skills/homelab-services.md;
  xdg.configFile."opencode/skills/home-dev/SKILL.md".source = ./skills/home-dev.md;
  xdg.configFile."opencode/skills/real-dev/SKILL.md".source = ./skills/real-dev.md;
  xdg.configFile."opencode/agents/reviewer.md".source = ./agents/reviewer.md;
}
