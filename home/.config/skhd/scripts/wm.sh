#!/usr/bin/env sh
# wm.sh <verb> <dir>  -- layout-aware window action, driven by skhd (WIN layer).
#   verb: focus | move | resize | split          dir: west | south | north | east
#
# Behavior follows the current space's yabai layout (single source of truth):
#   stack     -> focus k/j cycle the stack, h/l jump displays; move/resize/split no-op
#   bsp/float -> directional focus / warp / resize (the original tiling behavior)

verb="$1"
dir="$2"

if [ "$(yabai -m query --spaces --space | jq -r '.type')" = "stack" ]; then
  case "$verb" in
    focus)
      case "$dir" in
        north) yabai -m window --focus stack.prev ;;
        south) yabai -m window --focus stack.next ;;
        west)  yabai -m display --focus west ;;
        east)  yabai -m display --focus east ;;
      esac ;;
    *) : ;;   # move / resize / split: no-op in a stack
  esac
  exit 0
fi

# bsp / float  -- directional tiling actions
case "$verb" in
  focus)
    yabai -m window --focus "$dir" || yabai -m display --focus "$dir" ;;
  move)
    case "$dir" in
      west)  yabai -m window --warp west  || $(yabai -m window --display west && yabai -m display --focus west && yabai -m window --warp last) || yabai -m window --move rel:-10:0 ;;
      south) yabai -m window --warp south || $(yabai -m window --display south && yabai -m display --focus south) || yabai -m window --move rel:0:10 ;;
      north) yabai -m window --warp north || $(yabai -m window --display north && yabai -m display --focus north) || yabai -m window --move rel:0:-10 ;;
      east)  yabai -m window --warp east  || $(yabai -m window --display east && yabai -m display --focus east && yabai -m window --warp first) || yabai -m window --move rel:10:0 ;;
    esac ;;
  resize)
    case "$dir" in
      west)  yabai -m window --resize right:-100:0 || yabai -m window --resize left:-100:0 ;;
      south) yabai -m window --resize bottom:0:100 || yabai -m window --resize top:0:100 ;;
      north) yabai -m window --resize bottom:0:-100 || yabai -m window --resize top:0:-100 ;;
      east)  yabai -m window --resize right:100:0 || yabai -m window --resize left:100:0 ;;
    esac ;;
  split)
    yabai -m window --toggle split ;;
esac
