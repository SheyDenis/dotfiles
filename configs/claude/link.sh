#!/bin/bash
# Symlinks the Claude Code configs in this directory into ~/.claude (or $CLAUDE_CONFIG_DIR).
# Existing correct links are left alone. Anything else at a destination is reported, never changed.

set -u
shopt -s nullglob

src_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
dst_dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
status=0

# link SRC DST
link() {
  local src=$1 dst=$2
  if [[ -L $dst ]]; then
    if [[ $(readlink -f "$dst") == "$(readlink -f "$src")" ]]; then
      echo "ok: $dst already links to $src"
    else
      echo "ALERT: $dst is a symlink to a different location: $(readlink "$dst") (expected $src)" >&2
      status=1
    fi
  elif [[ -e $dst ]]; then
    echo "ALERT: $dst exists and is not a symlink" >&2
    status=1
  else
    mkdir -p "$(dirname "$dst")" && ln -s "$src" "$dst" && echo "linked: $dst -> $src"
  fi
}

for f in CLAUDE.md settings.json statusline.sh; do
  link "$src_dir/$f" "$dst_dir/$f"
done

for d in skills rules; do
  for item in "$src_dir/$d"/*; do
    link "$item" "$dst_dir/$d/$(basename "$item")"
  done
done

exit $status
