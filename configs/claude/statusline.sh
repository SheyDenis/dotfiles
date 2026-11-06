#!/bin/bash
# Claude Code status line, two rows. Reads the status JSON on stdin.
#
# Row 1: [HH:MM:SS][cwd (branch)] <session name> [+added -removed]
#   [HH:MM:SS]          local time, 24-hour.
#   [cwd (branch)]      current working directory in blue, git branch in parentheses if any.
#                       A cwd under $HOME is shown as ~/... instead of /home/...
#   session name        session_name from the JSON, plain. Omitted if the session has no name.
#   [+added -removed]   lines added in green, lines removed in red, for the session.
#
# Row 2: <model> <effort> <thinking> <context> [tokens] <rate limits> <cost> <ponytail>
#   model               Opus/Fable red, Sonnet orange, Haiku blue, any other model red.
#   effort              max/xhigh red, high orange, medium yellow, low blue, other gray. Omitted if absent.
#   thinking            "thinking" when extended thinking is enabled. Omitted otherwise.
#   context             percent of the context window used, with window size.
#                       Green up to 45%, orange above 45%, red above 80%.
#   tokens              session input and output tokens, e.g. [in 12.3k · out 4.5k].
#   rate limits         5-hour and 7-day usage percentages, e.g. 5h 3% · 7d 0%. Each omitted if absent.
#   cost                session cost in USD, e.g. $0.27.
#   ponytail            [PONYTAIL:<LEVEL>] for this project, e.g. [PONYTAIL:FULL]. Omitted when ponytail is off.
#                       ULTRA is amber, other levels dim green.

declare -A COLOR=(
  [RED]=31 [ORANGE]='38;5;208' [YELLOW]=33 [GREEN]=32 [BLUE]=34 [GRAY]=90
  [PONY_DIM]=108 [AMBER]=173
)

# colorize NAME STRING: wraps STRING in the color's escape code and a reset, then prints it.
colorize() { printf '\033[%sm%s\033[0m' "${COLOR[$1]}" "$2"; }

# fmt_k N: 12345 -> 12.3k, 800 -> 800.
fmt_k() {
  local n=${1:-0}
  n=${n%.*}
  if (( n >= 1000 )); then printf '%d.%dk' $((n / 1000)) $(((n % 1000) / 100)); else printf '%d' "$n"; fi
}

model_color() {
  case "${1,,}" in
    *opus*|*fable*) echo RED ;;
    *sonnet*) echo ORANGE ;;
    *haiku*) echo BLUE ;;
    *) echo RED ;;
  esac
}

effort_color() {
  case "$1" in
    max|xhigh) echo RED ;;
    high) echo ORANGE ;;
    medium) echo YELLOW ;;
    low) echo BLUE ;;
    *) echo GRAY ;;
  esac
}

input=$(cat)

# One jq call; fields joined with the unit separator, which bash does not treat as whitespace,
# so empty fields are kept in place. // false keeps a false thinking flag as "false", not "".
IFS=$'\x1f' read -r dir proj_json session model_id model_name effort think pct size tin tout \
  five seven cost added removed < <(
  jq -r '[
    (.workspace.current_dir // ""),
    (.workspace.project_dir // ""),
    (.session_name // ""),
    (.model.id // ""),
    (.model.display_name // ""),
    (.effort.level // ""),
    ((.thinking.enabled // false) | tostring),
    ((.context_window.used_percentage // "") | tostring),
    ((.context_window.context_window_size // "") | tostring),
    ((.context_window.total_input_tokens // 0) | tostring),
    ((.context_window.total_output_tokens // 0) | tostring),
    ((.rate_limits.five_hour.used_percentage // "") | tostring),
    ((.rate_limits.seven_day.used_percentage // "") | tostring),
    ((.cost.total_cost_usd // "") | tostring),
    ((.cost.total_lines_added // "") | tostring),
    ((.cost.total_lines_removed // "") | tostring)
  ] | join("\u001f")' <<< "$input"
)
dir=${dir:-$PWD}

# Git branch, without taking optional locks.
br=$(git -C "$dir" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)

# Row 1: time, cwd and branch, session name, lines changed. Paths under $HOME are shown with a ~ prefix.
shown=${dir/#"$HOME"/"~"}
where="$(colorize BLUE "$shown")${br:+ ($br)}"
row1="[$(date +%H:%M:%S)][$where]"
[[ -n $session ]] && row1+=" $session"
if [[ -n $added && -n $removed ]]; then
  row1+=" [$(colorize GREEN "+$added") $(colorize RED "-$removed")]"
fi

# Row 2 is built from parts, joined by single spaces.
parts=()

# Model and effort.
if [[ -n $model_id || -n $model_name ]]; then
  mname=${model_name:-$model_id}
  parts+=("$(colorize "$(model_color "${model_id:-$model_name}")" "$mname")")
fi
[[ -n $effort ]] && parts+=("$(colorize "$(effort_color "$effort")" "$effort")")

# Extended thinking.
[[ $think == true ]] && parts+=("thinking")

# Context window usage.
if [[ -n $pct ]]; then
  p=${pct%.*}
  if (( p > 80 )); then c=RED; elif (( p > 45 )); then c=ORANGE; else c=GREEN; fi
  ctx="ctx ${p}%"
  [[ -n $size ]] && ctx+=" of $(fmt_k "$size")"
  parts+=("$(colorize $c "$ctx")")
fi

# Session token usage.
parts+=("[in $(fmt_k "$tin") · out $(fmt_k "$tout")]")

# Rate limits, 5-hour and 7-day.
limits=()
[[ -n $five ]] && limits+=("5h ${five%.*}%")
[[ -n $seven ]] && limits+=("7d ${seven%.*}%")
(( ${#limits[@]} )) && parts+=("${limits[*]}")

# Session cost in USD.
[[ -n $cost ]] && parts+=("$(printf '$%.2f' "$cost")")

# Ponytail mode. The plugin keeps a per-project flag keyed by sha256 of the project dir,
# and only that file counts. Without a project dir, fall back to the shared flag.
cfg="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
proj="${CLAUDE_PROJECT_DIR:-$proj_json}"
proj=${proj%/}
if [[ -n $proj ]]; then
  flag="$cfg/ponytail-modes/$(printf '%s' "$proj" | sha256sum | cut -d' ' -f1)"
else
  flag="$cfg/.ponytail-active"
fi
if [[ -f $flag ]]; then
  mode=$(head -n1 "$flag" | tr -d '[:space:]')
  if [[ -n $mode ]]; then
    pc=PONY_DIM
    [[ $mode == ultra ]] && pc=AMBER
    parts+=("$(colorize $pc "[PONYTAIL:${mode^^}]")")
  fi
fi

row2="${parts[*]}"

printf '%s\n%s' "$row1" "$row2"
