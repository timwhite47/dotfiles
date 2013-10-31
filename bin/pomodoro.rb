#!/usr/bin/env ruby
# Encoding: UTF-8
#
# for use with ugol's pomodoro app (https://github.com/ugol/pomodoro) and tmux
# use applescript to set the time
# How to use it:

# 1. Open preferences from the pomodoro app
# 2. Choose scripts
# 3. Paste in the following:
#    Start: do shell script "~/Dropbox/dotfiles/bin/pomodoro reset mins:$mins passed:$passed time:$time"
#    Reset: do shell script "~/Dropbox/dotfiles/bin/pomodoro end"
#    End: do shell script "~/Dropbox/dotfiles/bin/pomodoro break"
#    Break End: do shell script "~/Dropbox/dotfiles/bin/pomodoro end"
#    Every 1 mins: do shell script "~/Dropbox/dotfiles/bin/pomodoro set $time"
# 4. in .tmux.conf you can call this script:
#    Example: set -g status-right "#(date '+%H:%M') | #(~/bin/pomodoro time) min"
#    Or, check out mine at: https://github.com/amiel/dotfiles/blob/master/home/tmux.conf

require 'pathname'

class Pomodoro
  TIME_FILE = Pathname.new(File.expand_path('~/.pomodoro_left_time'))
  attr_accessor :time_file

  def initialize(time_file=TIME_FILE)
    @time_file = time_file
  end

  def reset_timer(value=25)
    write_time_to_file(value)
  end

  def current_time
    read_time_from_file.to_i
  end

  def break
    write_time_to_file(' -- break -- ')
  end

  def finish
    write_time_to_file('')
  end

  def to_s
    time = read_time_from_file
    if time.match(/\d/)
      "#{ time }m left"
    else
      time
    end
  end

  def running?
    state == 'running'
  end

  def break?
    state == 'break'
  end

  def state
    if time.match(/\d/)
      'running'
    elsif time.match(/break/)
      'break'
    else
      ''
    end
  end

  def colors
    {
      'running' => '61',
      'break' => '174',
    }
  end

  def color
    colors[state]
  end

  def time
    @_time ||= @time_file.read
  end

  def read_time_from_file
    time
  end

  def write_time_to_file(value)
    File.open(@time_file, "w") do |f|
      f.write(value)
    end
    value
  end
end

command = ARGV.shift || 'time'
pomodoro = Pomodoro.new
case command
when 'time'
  string = pomodoro.to_s
  if pomodoro.running? || pomodoro.break?
    print "#[fg=colour#{pomodoro.color}]#[bg=colour#{pomodoro.color},fg=colour235]"
    # \xE2\x97\x80
    # A tomato
    print " \xF0\x9F\x8D\x85  " if pomodoro.running?
    print string
    puts ' #[bg=default,fg=default]'
  end
when 'reset'
  pomodoro.reset_timer
when 'set'
  pomodoro.reset_timer(ARGV[0].to_i - 1)
when 'break'
  pomodoro.break
when 'end'
  pomodoro.finish
when 'running'
  exit ! pomodoro.current_time.zero?
end

