#!/bin/bash

function EXT_COLOR () { echo -ne "\033[38;5;$1m"; }

function __git_parse_dirty {
  [[ $(git status 2> /dev/null | tail -n1) == "" ]] && echo "" && return
  [[ $(git status 2> /dev/null | tail -n1) == "nothing to commit (working directory clean)" ]] && printf "\033[32m✓\033[00m" && return
  printf "\[\033[31m\]✗\[\033[00m\]"
}

function __git_pairs {
  local pairs="$(git config --get user.initials 2>/dev/null)"
  if [ -n "$pairs" ];then
    echo -n "[$pairs] "
  fi
}

function color_prompt {

  # Pick colors from http://www.mudpedia.org/wiki/Xterm_256_colors
  local usercolor=$(EXT_COLOR 080)
  if $IS_REMOTE; then
    local hostcolor=$(EXT_COLOR 227)
  else
    local hostcolor=$(EXT_COLOR 063)
  fi

  local dircolor=$(EXT_COLOR 164)
  local gitcolor=$(EXT_COLOR 083)
  local paircolor=$(EXT_COLOR 179)
  # local gitcolor=$(EXT_COLOR 077)
  local NC="\e[0;m"

  if __command_exists rbenv; then
    local title="\[\033]0;\$(rbenv version-name)\007\]"
  fi

  if __command_exists __git_ps1; then
    export GIT_PS1_SHOWDIRTYSTATE=true
    export GIT_PS1_SHOWSTASHSTATE=true
    export GIT_PS1_SHOWUNTRACKEDFILES=true
    export GIT_PS1_SHOWUPSTREAM=verbose # or auto?
    local gitps1="\[${gitcolor}\]\$(__git_ps1 '(%s) ')\[${paircolor}\]\$(__git_pairs)\[${NC}\]"
  fi


  export PS1="$title\[${usercolor}\]\u@\[$NC\]\[${hostcolor}\]\h\[$NC\] \[${dircolor}\]\W\[$NC\] ${gitps1}$(echo -ne "\xe2\x87\x89") "
}

export PS1='\h:\u \W\$ '

if $IS_OSX && [ ! -z "$TERM_PROGRAM" ]; then
  case "$TERM_PROGRAM" in
    Apple_Terminal|xterm*|iTerm*) color_prompt ;;
  esac
else
  case "$TERM" in
    xterm*|screen*) color_prompt ;;
  esac
fi


unset make_prompt EXT_COLOR
