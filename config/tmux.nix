{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    tmuxPlugins.sensible tmuxPlugins.yank tmuxPlugins.logging
  ];

  programs.tmux = {
    enable = true;

    baseIndex = 1;
    clock24 = true;
    customPaneNavigationAndResize = true;
    escapeTime = 0;
    historyLimit = 100000;
    keyMode = "vi";
    reverseSplit = true;
    shortcut = "s";
    terminal = "screen-256color";

    extraConfig = ''
      # interaction
      setw -g mouse on
      setw -g monitor-activity on

      # style
      set -g status-style fg=colour246,bg=colour236
      set -g window-status-activity-style fg=colour235,bg=colour241
      set -g window-status-current-style fg=colour236,bg=colour245

      # key bindings
      bind -n M-h select-pane -L
      bind -n M-j select-pane -D
      bind -n M-k select-pane -U
      bind -n M-l select-pane -R

      bind-key M-j resize-pane -D
      bind-key M-k resize-pane -U
      bind-key M-h resize-pane -L
      bind-key M-l resize-pane -R

      bind -n M-Left select-pane -L
      bind -n M-Right select-pane -R
      bind -n M-Up select-pane -U
      bind -n M-Down select-pane -D

      bind -n S-Left  previous-window
      bind -n S-Right next-window

      # plugins
      set -g @logging-path '$HOME/tmp'
      set -g @screen-capture-path '$HOME/tmp'
      set -g @save-complete-history-path '$HOME/tmp'
    '';
  };
}
