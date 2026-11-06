# Secrets

- NEVER attempt to read secret-like files: `.env`, `.env.*`, `*.env`, `~/.netrc`, private keys, credential files, and similar.
- NEVER attempt to bypass a read/write restriction on such files by other means: `cat`, `head`, `tail`, `grep`, `sed`, `awk`, `less`, `cp`, `source`, opening the file in a Python/Node/etc. script, or any other shell trick that prints, copies or leaks their contents.
- If a task seems to need a secret file, stop and ask the user instead. If a permission denial occurs, do not work around it.

# Notifications

- When you need my attention (a question, approval, decision, or a finished long task), use the `notify` skill.
- Notify only if more than 120 seconds have passed since my last interaction (my last message or tool approval); otherwise I'm still watching, so skip it. Check the time with `date` if unsure.
- Exception: if I explicitly ask to be notified on completion, use the `notify` skill when done, even if less than 120 seconds have passed.

# Dependency source code

- When looking for the source code of a project dependency, first search within the current project's build/dependency directories (`.venv`, `.build`, `cmake-build-debug` and other CMake build dirs, etc.).
- If it is not there, search online for the dependency's git repository.
- NEVER start a search from `/`, `~/` or other huge search paths.
- If you still can't find it, ask me.

# DEV MARKER comments

- Comments of the form `<comment start> DEV MARKER - ...` (e.g. `// DEV MARKER - ...`, `# DEV MARKER - ...`, `-- DEV MARKER - ...`) are notes for me, the user, left in code.
- Ignore them completely: do not act on them, do not act on the code lines they mark, and do not mention them, unless I explicitly tell you to address something on lines marked with DEV MARKER.
- NEVER include DEV MARKER comments or their content in git commits, commit messages, or PR descriptions. When staging or committing, exclude hunks/lines containing them; if a hunk can't be split from one, ask me first.

# File change summary

- Whenever you modify, add, or remove files, end your final summary message with a list of the modified/added/removed files.
- For modified files, include how many lines were added and removed in each (e.g. `path/to/file: +12 / -3`).
- This list must be the last part of the summary message.
