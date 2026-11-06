# Claude Code Configs

## Linux

### Files location

```
~/.claude/
```

### Contents

| Source (this directory) | Destination                  |
|-------------------------|------------------------------|
| `CLAUDE.md`             | `~/.claude/CLAUDE.md`        |
| `settings.json`         | `~/.claude/settings.json`    |
| `statusline.sh`         | `~/.claude/statusline.sh`    |
| `skills/<name>`         | `~/.claude/skills/<name>`    |
| `rules/<name>`          | `~/.claude/rules/<name>`     |

### Usage

Run the link script:

```bash
./link.sh
```

It creates a symlink for each file above, one per skill and one per rule. Set `CLAUDE_CONFIG_DIR` to use a destination other than `~/.claude`.

For each destination:

- Missing: the symlink is created (parent directories too).
- Already a symlink to the right file: left as is.
- A symlink to a different location, or a regular file/directory: an `ALERT` message is printed to stderr and nothing is changed. The script then exits with status 1. Resolve it by hand (move or delete the destination) and rerun.

New skills or rules added to this directory are picked up by rerunning the script.
