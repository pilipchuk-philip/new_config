{ pkgs, ... }:

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
in
{
  programs.tmux = {
    enable = true;
    mouse = true;
    keyMode = "vi";

    plugins = with pkgs.tmuxPlugins; [
      sensible
      vim-tmux-navigator
      yank
      cpu
      battery
      weather
      tmuxPowerZoom
    ];

    extraConfig = ''
      set-option -g status-position top
      set -g default-terminal "tmux-256color"
      set -s set-clipboard on

      set -g base-index 1
      set -g pane-base-index 1
      set-window-option -g pane-base-index 1
      set-option -g renumber-windows on
      set -g pane-active-border-style "fg=brightblue"

      # status bar
      set -g status on
      set -g status-style bg=#1E1E2E,fg=white
      set -g status-left "#[bg=black,fg=white] 󰌢 #S #[bg=black,fg=white] "
      set -g status-right "#[fg=blue]  #{cpu_percentage}  #{battery_percentage} #[fg=yellow] CPH:#{weather}   %Y-%m-%d #[fg=green]  %H:%M #[default]"
      setw -g window-status-format " #I:#W "
      setw -g window-status-current-format "#[fg=black,bg=#87afff] #I:#W #[default]"
      setw -g window-status-style fg=white,bg=black
      set -g status-right-length 200
      set -g @tmux-weather-location "Copenhagen"
      set -g status-interval 5

      # Home Manager loads plugins before this extraConfig block.
      # Re-run interpolation plugins after status-right is defined.
      run-shell ${pkgs.tmuxPlugins.cpu.rtp}
      run-shell ${pkgs.tmuxPlugins.battery.rtp}
      run-shell ${pkgs.tmuxPlugins.weather.rtp}

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
    '';
  };
}
