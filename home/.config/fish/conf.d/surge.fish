status is-interactive || exit

set --global _surge_git _surge_git_$fish_pid
set --query surge_color_pwd || set --global surge_color_pwd magenta
set --query surge_color_git || set --global surge_color_git blue
set --query surge_color_git_branch || set --global surge_color_git_branch $surge_color_pwd
set --query surge_color_git_branch_clean || set --global surge_color_git_branch_clean brgreen
set --query surge_color_git_branch_dirty || set --global surge_color_git_branch_dirty brred
set --query surge_color_git_ahead || set --global surge_color_git_ahead brblue
set --query surge_color_git_behind || set --global surge_color_git_behind green
set --query surge_color_error || set --global surge_color_error red
set --query surge_color_prompt || set --global surge_color_prompt blue
set --query surge_color_duration || set --global surge_color_duration yellow
set --query surge_symbol_prompt || set --global surge_symbol_prompt '❯ '
set --query surge_symbol_git_branch || set --global surge_symbol_git_branch '•'
set --query surge_symbol_git_ahead || set --global surge_symbol_git_ahead '↑'
set --query surge_symbol_git_behind || set --global surge_symbol_git_behind '↓'
set --query surge_multiline || set --global surge_multiline false
set --query surge_cmd_duration_threshold || set --global surge_cmd_duration_threshold 1000

function $_surge_git --on-variable $_surge_git
  commandline --function repaint
end

function __surge_pwd --on-variable PWD --on-variable surge_ignored_git_paths
  set --local git_root (command git --no-optional-locks rev-parse --show-toplevel 2>/dev/null)
  set --local git_base (string replace --all --regex -- "^.*/" "" "$git_root")
  set --local path_sep /


  if set --query git_root[1] && ! contains -- $git_root $surge_ignored_git_paths
    set --erase _surge_skip_git_prompt
  else
    set --global _surge_skip_git_prompt
  end

  if test -n "$git_base"
    set --global _surge_pwd $git_base
  else
    set --global _surge_pwd (string replace --ignore-case -- ~ \~ $PWD | string replace --all --regex -- "^.*/" "")
  end
end

function __surge_postexec --on-event fish_postexec
  set --local last_status $pipestatus
  set --local prompt_status

  for code in $last_status
    if test $code -ne 0
      set prompt_status "$_surge_color_error"(echo $last_status) "$_surge_newline"
      break
    end
  end

  set --global _surge_status "$_surge_color_prompt$prompt_status"

  test "$CMD_DURATION" -lt $surge_cmd_duration_threshold && set _surge_cmd_duration && return

  set --local secs (math --scale=1 $CMD_DURATION/1000 % 60)
  set --local mins (math --scale=0 $CMD_DURATION/60000 % 60)
  set --local hours (math --scale=0 $CMD_DURATION/3600000)

  set --local out

  test $hours -gt 0 && set --local --append out $hours"h"
  test $mins -gt 0 && set --local --append out $mins"m"
  test $secs -gt 0 && set --local --append out $secs"s"
  set --local out "$_surge_color_duration$out "

  set --global _surge_cmd_duration $out
  set --query prompt_status || set --global _surge_status "$_surge_status$_surge_newline"

end

function __surge_prompt --on-event fish_prompt
  set --query _surge_prompt || set --global _surge_prompt "$_surge_color_prompt$surge_symbol_prompt"
  set --query _surge_pwd || __surge_pwd

  command kill $_surge_last_pid 2>/dev/null

  set --query _surge_skip_git_prompt && set $_surge_git && return
  fish --private --command "
    set branch \"$_surge_color_git_branch\$(command git symbolic-ref --short HEAD 2>/dev/null)\"
    set branch_icon \"$_surge_color_git_branch_clean$surge_symbol_git_branch \"

    test -z \"\$$_surge_git\" && set --universal $_surge_git \"\$branch_icon\$branch \"

    command git diff-index --quiet HEAD 2>/dev/null
      test \$status -eq 1 ||
        count (command git ls-files --others --exclude-standard (command git rev-parse --show-toplevel)) >/dev/null &&
        set branch_icon \"$_surge_color_git_branch_dirty$surge_symbol_git_branch \"

    for fetch in $surge_fetch false
      command git rev-parse --abbrev-ref --symbolic-full-name @{u} &>/dev/null
      set -l hasremote \$status
      command git rev-list --count --left-right @{upstream}...@ 2>/dev/null | read behind ahead

      set -l upstream
      test \$hasremote -eq 0 && test \$ahead -gt 0 && set upstream \"\$upstream$_surge_color_git_ahead\$ahead$surge_symbol_git_ahead\"
      test \$hasremote -eq 0 && test \$behind -gt 0 && set upstream \"\$upstream$_surge_color_git_behind\$behind$surge_symbol_git_behind\"
      set --query upstream && set upstream \" \$upstream\"

      set --universal $_surge_git \"\$branch_icon\$branch\$upstream\"

      if test \$fetch = true && test \$hasremote -eq 0
        # Check if remote URL uses SSH and prevent retries on auth failure
        set -l remote_url (command git remote get-url (command git rev-parse --abbrev-ref --symbolic-full-name @{u} | string replace '/' ' ' | read -l remote_name rest; echo \$remote_name) 2>/dev/null)
        if string match -q 'git@*' \$remote_url || string match -q 'ssh://*' \$remote_url
          # SSH-only auth protection: set GIT_SSH_COMMAND to disable password prompts and limit connection attempts
          env GIT_SSH_COMMAND='ssh -o BatchMode=yes -o ConnectTimeout=5 -o ConnectionAttempts=1' command git fetch --no-tags 2>/dev/null
        end
      end
    end
  " &

  set --global _surge_last_pid $last_pid
end

function __surge_fish_exit --on-event fish_exit
  set --erase $_surge_git
end

set --global surge_color_normal (set_color normal)

for color in surge_color_{pwd,git,git_branch,git_branch_clean,git_branch_dirty,git_ahead,git_behind,error,prompt,duration}
  function $color --on-variable $color --inherit-variable color
    set --query $color && set --global _$color (set_color $$color)
  end && $color
end

function surge_multiline --on-variable surge_multiline
  if test "$surge_multiline" = true
    set --global _surge_newline "\n"
  else
    set --global _surge_newline ""
  end
end && surge_multiline


function surge_prompt
  set -l lprompt "$_surge_cmd_duration$_surge_status$_surge_prompt$surge_color_normal"

  echo -e $lprompt
end

function surge_git
  set -l rprompt "$_surge_color_pwd$_surge_pwd"
  set --query _surge_git && string length -- $_surge_git &>/dev/null && set -l rprompt "$rprompt $$_surge_git"
  set -l rprompt "$rprompt$surge_color_normal "

  echo -e $rprompt
end
