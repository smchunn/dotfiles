status is-interactive || exit

set --global _hydro_git _hydro_git_$fish_pid

function $_hydro_git --on-variable $_hydro_git
  set --global _hydro_git_branch $$_hydro_git[1][1]
  set --global _hydro_git_staged $$_hydro_git[1][2]
  set --global _hydro_git_unstaged $$_hydro_git[1][3]
  set --global _hydro_git_untracked $$_hydro_git[1][4]
  set --global _hydro_git_unmerged $$_hydro_git[1][5]
  set --global _hydro_git_ahead $$_hydro_git[1][6]
  set --global _hydro_git_behind $$_hydro_git[1][7]
  commandline --function repaint
end

function _hydro_pwd --on-variable PWD --on-variable hydro_ignored_git_paths --on-variable fish_prompt_pwd_dir_length
  set --local git_root (command git --no-optional-locks rev-parse --show-toplevel 2>/dev/null)
  set --local git_base (string replace --all --regex -- "^.*/" "" "$git_root")
  set --local path_sep /

  test "$fish_prompt_pwd_dir_length" = 0 && set path_sep

  if set --query git_root[1] && ! contains -- $git_root $hydro_ignored_git_paths
    set --erase _hydro_skip_git_prompt
  else
    set --global _hydro_skip_git_prompt
  end

  if test -n "$git_base"
    set --global _hydro_pwd $git_base
  else
    set --global _hydro_pwd (string replace --ignore-case -- ~ \~ $PWD | string replace --all --regex -- "^.*/" "")
  end
end

function _hydro_postexec --on-event fish_postexec
  set --local last_status $pipestatus
  set --global _hydro_status "$_hydro_newline$_hydro_color_prompt$hydro_symbol_prompt"

  for code in $last_status
    if test $code -ne 0
      set --global _hydro_status "$_hydro_color_error"(echo $last_status)" $_hydro_newline$_hydro_color_prompt$_hydro_color_error$hydro_symbol_prompt"
      break
    end
  end

  test "$CMD_DURATION" -lt $hydro_cmd_duration_threshold && set _hydro_cmd_duration && return

  set --local secs (math --scale=1 $CMD_DURATION/1000 % 60)
  set --local mins (math --scale=0 $CMD_DURATION/60000 % 60)
  set --local hours (math --scale=0 $CMD_DURATION/3600000)

  set --local out

  test $hours -gt 0 && set --local --append out $hours"h"
  test $mins -gt 0 && set --local --append out $mins"m"
  test $secs -gt 0 && set --local --append out $secs"s"

  set --global _hydro_cmd_duration "$out "
end

function _hydro_prompt --on-event fish_prompt
  set --query _hydro_status || set --global _hydro_status "$_hydro_newline$_hydro_color_prompt$hydro_symbol_prompt"
  set --query _hydro_pwd || _hydro_pwd

  command kill $_hydro_last_pid 2>/dev/null

  set --query _hydro_skip_git_prompt && set $_hydro_git && return
  # check lucid theme async
  fish --private --command "
    set branch (command git symbolic-ref --short HEAD 2>/dev/null)

    test -z \"\$$_hydro_git\" && set --universal $_hydro_git[1] \"\$branch\"

    command git diff-index --quiet HEAD 2>/dev/null

    set -l status_response (command git status --porcelain -b 2> /dev/null)

    set -l staged (printf \"%s\n\" \$status_response | grep '^[AMDRC].' | wc -l | string trim)
    set -l unstaged (printf \"%s\n\" \$status_response | grep '^.[MD]' | wc -l | string trim)
    set -l untracked (printf \"%s\n\" \$status_response | grep '^??' | wc -l | string trim)
    set -l unmerged (printf \"%s\n\" \$status_response | grep '^UU' | wc -l | string trim)
    set --universal $_hydro_git\[2] \"\$staged\"
    set --universal $_hydro_git\[3] \"\$unstaged\"
    set --universal $_hydro_git\[4] \"\$untracked\"
    set --universal $_hydro_git\[5] \"\$unmerged\"


    for fetch in $hydro_fetch false
      command git rev-list --count --left-right @{upstream}...@ 2>/dev/null | read behind ahead

      set --universal $_hydro_git\[6] \"\$ahead\"
      set --universal $_hydro_git\[7] \"\$behind\"

      test \$fetch = true && command git fetch --no-tags 2>/dev/null
    end
  " &

  set --global _hydro_last_pid $last_pid
end

function _hydro_fish_exit --on-event fish_exit
  set --erase $_hydro_git
end

set --global hydro_color_normal (set_color normal)

for color in hydro_color_{pwd,git,error,prompt,duration,start}
  function $color --on-variable $color --inherit-variable color
    set --query $color && set --global _$color (set_color $$color)
  end && $color
end

function hydro_multiline --on-variable hydro_multiline
  if test "$hydro_multiline" = true
    set --global _hydro_newline "\n"
  else
    set --global _hydro_newline ""
  end
end && hydro_multiline

set --query hydro_color_pwd || set --global hydro_color_pwd magenta
set --query hydro_color_git || set --global hydro_color_git blue
set --query hydro_color_error || set --global hydro_color_error red
set --query hydro_color_prompt || set --global hydro_color_prompt blue
set --query hydro_color_duration || set --global hydro_color_duration yellow
set --query hydro_color_start || set --global hydro_color_start green
set --query hydro_symbol_prompt || set --global hydro_symbol_prompt '❯ '
set --query hydro_symbol_arrow || set --global hydro_symbol_arrow '➜'
set --query hydro_symbol_git_dirty || set --global hydro_symbol_git_dirty ''
set --query hydro_symbol_git_staged || set --global hydro_symbol_git_staged '+'
set --query hydro_symbol_git_unstaged || set --global hydro_symbol_git_unstaged '~'
set --query hydro_symbol_git_untracked || set --global hydro_symbol_git_untracked '?'
set --query hydro_symbol_git_ahead || set --global hydro_symbol_git_ahead ''
set --query hydro_symbol_git_behind || set --global hydro_symbol_git_behind ''
set --query hydro_multiline || set --global hydro_multiline false
set --query hydro_cmd_duration_threshold || set --global hydro_cmd_duration_threshold 1000

function hydro_left
  set -l lprompt
  set -l lprompt "$lprompt$_hydro_color_duration$_hydro_cmd_duration"
  set -l lprompt "$lprompt$_hydro_status"
  echo -e "$lprompt"
end

function hydro_right
  set -l rprompt "$_hydro_color_pwd$_hydro_pwd"
  set --query _hydro_git_branch && string length -- $_hydro_git_branch &>/dev/null && set -l rprompt "$rprompt $hydro_color_normal$hydro_symbol_arrow"
  set --query _hydro_git_branch && string length -- $_hydro_git_branch &>/dev/null && set -l rprompt "$rprompt $_hydro_color_pwd$_hydro_git_branch "
  set --query _hydro_git_staged && string length -- $_hydro_git_staged &>/dev/null && test $_hydro_git_staged -gt 0 && set -l rprompt "$rprompt$_hydro_color_start$_hydro_git_staged$hydro_symbol_git_staged"
  set --query _hydro_git_unstaged && string length -- $_hydro_git_unstaged &>/dev/null && test $_hydro_git_unstaged -gt 0 && set -l rprompt "$rprompt$_hydro_color_duration$_hydro_git_unstaged$hydro_symbol_git_unstaged"
  set --query _hydro_git_untracked && string length -- $_hydro_git_untracked &>/dev/null && test $_hydro_git_untracked -gt 0 && set -l rprompt "$rprompt$_hydro_color_error$_hydro_git_untracked$hydro_symbol_git_untracked"
  set --query _hydro_git_ahead && string length -- $_hydro_git_ahead &>/dev/null && test $_hydro_git_ahead -gt 0 && set -l rprompt "$rprompt$_hydro_color_git$_hydro_git_ahead$hydro_symbol_git_ahead"
  set --query _hydro_git_behind && string length -- $_hydro_git_behind &>/dev/null && test $_hydro_git_behind -gt 0 && set -l rprompt "$rprompt$_hydro_color_git$_hydro_git_behind$hydro_symbol_git_behind"

  echo $rprompt" "
end
