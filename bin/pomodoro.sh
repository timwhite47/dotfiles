#!/bin/bash

# for use with ugol's pomodoro app (https://github.com/ugol/pomodoro) and tmux
# use applescript to set the time
# How to use it:

# 1. Open preferences from the pomodoro app
# 2. Choose scripts
# 3. Paste in the following:
#    Start: do shell script "~/Dropbox/dotfiles/bin/pomodoro set $time"
#    Reset: do shell script "~/Dropbox/dotfiles/bin/pomodoro end"
#    End: do shell script "~/Dropbox/dotfiles/bin/pomodoro break"
#    Break End: do shell script "~/Dropbox/dotfiles/bin/pomodoro end"
#    Every 1 mins: do shell script "~/Dropbox/dotfiles/bin/pomodoro set $time"
# 4. in .tmux.conf you can call this script:
#    Example: set -g status-right "#(date '+%H:%M') | #(~/bin/pomodoro time) min"
#    Or, check out mine at: https://github.com/amiel/dotfiles/blob/master/home/tmux.conf

file=~/.pomodoro_time_left

function set_time {
  echo -n $1 > $file
}

function current_time {
  cat $file
}

function is_running {
  current_time | egrep -q '\d'
}

function is_break {
  current_time | egrep -q 'break'
}

function color {
  is_running && echo 61
  is_break && echo 174
}

function pomodoro_string {
  is_running && echo -n "$(current_time)m left"
  is_break && current_time
}


case $1 in
  set)
    set_time $2
    ;;
  break)
    set_time ' -- break -- '
    ;;
  end)
    set_time ''
    ;;
  *) # Or time)
    t=`current_time`

    if is_running || is_break; then
      echo -n "#[fg=colour$(color)]#[bg=colour$(color),fg=colour235]"
      # \xE2\x97\x80
      # A tomato
      is_running && echo -n " \xF0\x9F\x8D\x85  "
      pomodoro_string
      echo ' #[bg=default,fg=default]'
    fi
    ;;
esac

