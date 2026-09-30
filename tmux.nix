{ pkgs, lib, ... }:

let
  tmuxPowerZoom = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "tmux-power-zoom";
    rtpFilePath = "power-zoom.tmux";
    version = "1.0.0";
    src = pkgs.fetchFromGitHub {
      owner = "jaclu";
      repo = "tmux-power-zoom";
      rev = "v1.0.0";
      sha256 = "020km8zlfj8jhlg6xn65syn75z9xyyl2gnlgrhx96b1rl2rq8nfc";
    };
  };
  agentSidebarVersion = "0.13.0";
  # Pre-built release binary (matches upstream's own TPM install path) instead
  # of building the Rust source, picked per-platform since this module is
  # shared between the Linux and Darwin home-manager targets.
  agentSidebarBinary =
    if pkgs.stdenv.hostPlatform.isDarwin then
      pkgs.fetchurl {
        url = "https://github.com/hiroppy/tmux-agent-sidebar/releases/download/v${agentSidebarVersion}/tmux-agent-sidebar-darwin-aarch64";
        sha256 = "18r3iijfv4q16spnykfpc62f9c3qcc0ww54ri0a2drvsngqzmiv1";
      }
    else
      pkgs.fetchurl {
        url = "https://github.com/hiroppy/tmux-agent-sidebar/releases/download/v${agentSidebarVersion}/tmux-agent-sidebar-linux-x86_64";
        sha256 = "0i73329lvlrp071ryzdn0jgx3dmxc7q9fxixikiwcx504yirar70";
      };
  tmuxAgentSidebar = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "tmux-agent-sidebar";
    path = "tmux-agent-sidebar";
    rtpFilePath = "tmux-agent-sidebar.tmux";
    version = agentSidebarVersion;
    src = pkgs.fetchFromGitHub {
      owner = "hiroppy";
      repo = "tmux-agent-sidebar";
      rev = "v${agentSidebarVersion}";
      sha256 = "1hka38mkhazrf33f9wdjba8ravcscrkm26fd6fvjavfnrf08nain";
    };
    nativeBuildInputs = lib.optionals pkgs.stdenv.hostPlatform.isDarwin [ pkgs.darwin.sigtool ];
    postInstall =
      ''
        install -Dm755 ${agentSidebarBinary} $out/share/tmux-plugins/tmux-agent-sidebar/bin/tmux-agent-sidebar
      ''
      # Apple Silicon refuses to run an unsigned binary; ad-hoc sign it like
      # nixpkgs' own opencode package does for the same reason.
      + lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
        codesign --force --sign - $out/share/tmux-plugins/tmux-agent-sidebar/bin/tmux-agent-sidebar
      '';
  };
  tmuxWeatherCached = pkgs.writeShellApplication {
    name = "tmux-weather-cached";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.curl
      pkgs.gnused
    ];
    text = ''
      location="''${TMUX_WEATHER_LOCATION:-Copenhagen}"
      units="''${TMUX_WEATHER_UNITS:-m}"
      format="''${TMUX_WEATHER_FORMAT:-1}"
      ttl="''${TMUX_WEATHER_TTL_SECONDS:-1800}"

      cache_dir="''${XDG_CACHE_HOME:-$HOME/.cache}/tmux"
      cache_file="$cache_dir/weather"
      stamp_file="$cache_dir/weather.timestamp"
      lock_dir="$cache_dir/weather.lock"

      mkdir -p "$cache_dir"
      now="$(date +%s)"

      if [ -s "$cache_file" ] && [ -s "$stamp_file" ]; then
        stamp="$(cat "$stamp_file" 2>/dev/null || printf 0)"
        if [ "$((now - stamp))" -lt "$ttl" ]; then
          cat "$cache_file"
          exit 0
        fi
      fi

      if ! mkdir "$lock_dir" 2>/dev/null; then
        if [ -s "$cache_file" ]; then
          cat "$cache_file"
        fi
        exit 0
      fi
      trap 'rmdir "$lock_dir" 2>/dev/null || true' EXIT

      value="$(curl -fsSL --max-time 3 "https://wttr.in/$location?$units&format=$format" \
        | sed 's/[[:space:]]km/km/g' || true)"

      if [ -n "$value" ]; then
        printf '%s' "$value" > "$cache_file"
        printf '%s' "$now" > "$stamp_file"
        printf '%s' "$value"
      elif [ -s "$cache_file" ]; then
        cat "$cache_file"
      else
        printf '%s' '--'
      fi
    '';
  };
in
{
  programs.tmux = {
    enable = true;
    mouse = true;
    keyMode = "vi";

    plugins = [
      pkgs.tmuxPlugins.sensible
      pkgs.tmuxPlugins.vim-tmux-navigator
      pkgs.tmuxPlugins.yank
      pkgs.tmuxPlugins.resurrect
      pkgs.tmuxPlugins.cpu
      pkgs.tmuxPlugins.battery
      pkgs.tmuxPlugins.extrakto
      tmuxPowerZoom
      tmuxAgentSidebar
      # continuum must load after resurrect.
      pkgs.tmuxPlugins.continuum
    ];

    extraConfig = ''
      set-option -g status-position top
      # tmux-continuum: auto-restore the last saved session on tmux start
      # (tmux-resurrect already provides the save/restore commands).
      set -g @continuum-restore 'on'
      set -g default-terminal "tmux-256color"
      set -s set-clipboard on
      set -g extended-keys on
      set -g focus-events on
      set -as terminal-features ',xterm-ghostty:RGB:clipboard:extkeys'
      # vellum.nvim needs this to draw images (Kitty/Ghostty graphics protocol) through tmux.
      set -g allow-passthrough on

      set -g base-index 1
      set -g pane-base-index 1
      set-window-option -g pane-base-index 1
      set-option -g renumber-windows on
      # Ghostty's built-in Ayu palette (home/modules/terminal.nix).
      set -g pane-active-border-style "fg=#59c2ff"

      # status bar
      set -g status on
      set -g status-style bg=#0b0e14,fg=#bfbdb6
      set -g status-left "#[bg=#11151c,fg=#ffb454] 󰌢 #S #[bg=#11151c,fg=#bfbdb6] "
      set -g status-left-length 200
      set -g status-right "#[fg=#59c2ff]  #{cpu_percentage}  #{battery_percentage} #[fg=#ffb454] CPH:#(${tmuxWeatherCached}/bin/tmux-weather-cached)   %Y-%m-%d #[fg=#aad94c]  %H:%M #[default]"
      setw -g window-status-format " #I:#W "
      setw -g window-status-current-format "#[fg=#0b0e14,bg=#ffb454] #I:#W #[default]"
      setw -g window-status-style fg=#686868,bg=#0b0e14
      set -g status-right-length 200
      set -g status-interval 10

      # Home Manager loads plugins before this extraConfig block.
      # Re-run interpolation plugins after status-right is defined.
      run-shell ${pkgs.tmuxPlugins.cpu.rtp}
      run-shell ${pkgs.tmuxPlugins.battery.rtp}

      is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf|pipenv|poetry)(diff)?$'"
      bind-key -n C-h if-shell "$is_vim" 'send-keys C-h' 'select-pane -L'
      bind-key -n C-j if-shell "$is_vim" 'send-keys C-j' 'select-pane -D'
      bind-key -n C-k if-shell "$is_vim" 'send-keys C-k' 'select-pane -U'
      bind-key -n C-l if-shell "$is_vim" 'send-keys C-l' 'select-pane -R'
      bind-key -n C-\\ if-shell "$is_vim" 'send-keys C-\\' 'select-pane -l'

      bind-key -T copy-mode-vi C-h select-pane -L
      bind-key -T copy-mode-vi C-j select-pane -D
      bind-key -T copy-mode-vi C-k select-pane -U
      bind-key -T copy-mode-vi C-l select-pane -R

      # Prefix-based pane navigation.
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      unbind-key C-/
      unbind-key C-_

      # Smooth wheel scrolling: 1 line per tick (default is ~5).
      bind-key -T root         WheelUpPane   if-shell -F -t = "#{?pane_in_mode,1,#{alternate_on}}" "send-keys -M" "copy-mode -e ; send-keys -N1 -X scroll-up"
      bind-key -T root         WheelDownPane if-shell -F -t = "#{?pane_in_mode,1,#{alternate_on}}" "send-keys -M" "send-keys -N1 -X scroll-down"
      bind-key -T copy-mode-vi WheelUpPane   send-keys -N1 -X scroll-up
      bind-key -T copy-mode-vi WheelDownPane send-keys -N1 -X scroll-down
    '';
  };

  # Wires OpenCode into tmux-agent-sidebar without touching anything else
  # that might live under ~/.config/opencode/plugins/.
  xdg.configFile."opencode/plugins/tmux-agent-sidebar.js".source =
    "${tmuxAgentSidebar}/share/tmux-plugins/tmux-agent-sidebar/.opencode/plugins/tmux-agent-sidebar.js";
}
