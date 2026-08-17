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

  tmuxAgentSidebarBin = pkgs.rustPlatform.buildRustPackage {
    pname = "tmux-agent-sidebar";
    version = "0.13.0";
    src = pkgs.fetchFromGitHub {
      owner = "hiroppy";
      repo = "tmux-agent-sidebar";
      rev = "v0.13.0";
      hash = "sha256-NiqLgMvWbSW3M80ZUWdmmm2VkVqy8eTGcPkrOCsaasI=";
    };
    cargoHash = "sha256-mOEs2J1o9VeVOXY55r8O52TqoM2GuYU3tVoh5h+yH0s=";
    doCheck = false;
    buildInputs = lib.optionals pkgs.stdenv.isLinux [
      pkgs.xorg.libxcb
    ];
  };

  tmuxAgentSidebar = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "tmux-agent-sidebar";
    rtpFilePath = "tmux-agent-sidebar.tmux";
    version = "0.13.0";
    src = pkgs.fetchFromGitHub {
      owner = "hiroppy";
      repo = "tmux-agent-sidebar";
      rev = "v0.13.0";
      hash = "sha256-NiqLgMvWbSW3M80ZUWdmmm2VkVqy8eTGcPkrOCsaasI=";
    };
    postInstall = ''
      mkdir -p $target/bin
      ln -sf ${tmuxAgentSidebarBin}/bin/tmux-agent-sidebar $target/bin/tmux-agent-sidebar
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
  # Expose the sidebar binary in user PATH so the opencode plugin's
  # fallback (`spawn("tmux-agent-sidebar", ["hook", "opencode", …])`)
  # actually resolves. Without it hooks are silently swallowed and the
  # sidebar never learns about opencode panes.
  home.packages = [ tmuxAgentSidebarBin ];

  xdg.configFile."opencode/plugins/tmux-agent-sidebar.js".source =
    "${tmuxAgentSidebar.rtp}/.opencode/plugins/tmux-agent-sidebar.js";

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
      tmuxPowerZoom
      tmuxAgentSidebar
    ];

    extraConfig = ''
      set-option -g status-position top
      set -g default-terminal "tmux-256color"
      set -s set-clipboard on
      set -g extended-keys on
      set -g focus-events on
      set -as terminal-features ',xterm-ghostty:RGB:clipboard:extkeys'

      set -g base-index 1
      set -g pane-base-index 1
      set-window-option -g pane-base-index 1
      set-option -g renumber-windows on
      set -g pane-active-border-style "fg=brightblue"

      # status bar
      set -g status on
      set -g status-style bg=#1E1E2E,fg=white
      set -g status-left "#[bg=black,fg=white] 󰌢 #S #[bg=black,fg=white] "
      set -g status-right "#[fg=blue]  #{cpu_percentage}  #{battery_percentage} #[fg=yellow] CPH:#(${tmuxWeatherCached}/bin/tmux-weather-cached)   %Y-%m-%d #[fg=green]  %H:%M #[default]"
      setw -g window-status-format " #I:#W "
      setw -g window-status-current-format "#[fg=black,bg=#87afff] #I:#W #[default]"
      setw -g window-status-style fg=white,bg=black
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
}
