#!/usr/bin/env sh
# wm.sh <verb> <dir>  -- rotational window action, driven by skhd (WM layer).
#   verb: focus | swap        dir: next | prev
#
# yabai's own `window --focus next|prev` / `--swap next|prev` do NOT wrap at the
# ends of the window list. This walks the space's window ring (skipping minimized
# windows) and wraps around, so focus/swap rotate continuously in either direction.

verb="$1"
dir="$2"

# prev = walk the reversed ring; next = forward ring
[ "$dir" = next ] && rev='' || rev='reverse |'

target=$(yabai -m query --windows --space | jq -r "
  [ .[] | select(.[\"is-minimized\"]? != true) ]
  | sort_by(.frame.y, .frame.x, .id) | $rev . as \$w
  | (\$w | map(.[\"has-focus\"]?) | index(true)) as \$i
  | if \$i == null then \$w[0].id else \$w[((\$i + 1) % (\$w | length))].id end")

[ -z "$target" ] && exit 0
[ "$target" = null ] && exit 0

case "$verb" in
  focus) yabai -m window --focus "$target" ;;
  swap)  yabai -m window --swap  "$target" ;;
esac
