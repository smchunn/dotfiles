#!/usr/bin/env sh
# focus-app.sh <AppName>
#
# Focus a macOS app from the smcboard40 APP layer (skhd -> Hyper chord -> here):
#   - if the app has no (non-minimized) windows, open it
#   - otherwise focus the next window of that app, wrapping around
#
# <AppName> must match yabai's ".app" value (case-sensitive), e.g.
# kitty, Safari, ChatGPT, Mail, Calendar.

app="$1"
[ -z "$app" ] && { echo "usage: focus-app.sh <AppName>" >&2; exit 1; }

next=$(yabai -m query --windows | jq -r --arg app "$app" '
  [ .[] | select(.app == $app and (.["is-minimized"] | not)) ] | sort_by(.id) as $w
  | ($w | map(.["has-focus"]) | index(true)) as $i
  | if   ($w | length) == 0 then "OPEN"
    elif $i == null          then ($w[0].id | tostring)
    else ($w[(($i + 1) % ($w | length))].id | tostring)
    end')

if [ "$next" = "OPEN" ]; then
  open -a "$app"
else
  yabai -m window --focus "$next"
fi
