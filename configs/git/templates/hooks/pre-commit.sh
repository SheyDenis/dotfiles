#!/bin/bash

if git rev-parse --verify HEAD >/dev/null 2>&1; then
  against=HEAD
else
  # Initial commit: diff against an empty tree object
  against=4b825dc642cb6eb9a060e54bf8d69288fbee4904
fi

if [[ -f "${HOME}/git/pre-commit-config.yaml" ]]; then
  # Global pre-commit hooks.
  HERE="$(cd "$(dirname "$0")" && pwd)"
  INSTALL_PYTHON="$(git rev-parse --show-toplevel)/.venv/bin/python"
  ARGS=(hook-impl "--config=${HOME}/git/pre-commit-config.yaml" "--hook-type=pre-commit" --hook-dir "$HERE" -- "$@")

  if [ -x "$INSTALL_PYTHON" ]; then
    exec "$INSTALL_PYTHON" -mpre_commit "${ARGS[@]}"
  elif command -v pre-commit >/dev/null; then
    exec pre-commit "${ARGS[@]}"
  else
    echo '`pre-commit` not found.  Did you forget to activate your virtualenv?' 1>&2
    exit 1
  fi
fi

# pre-commit framework hooks.
if [[ -f "$(git rev-parse --show-toplevel)/.pre-commit-config.yaml" ]]; then
  HERE="$(cd "$(dirname "$0")" && pwd)"
  INSTALL_PYTHON="$(git rev-parse --show-toplevel)/.venv/bin/python"
  ARGS=(hook-impl "--config=.pre-commit-config.yaml" "--hook-type=pre-commit" --hook-dir "$HERE" -- "$@")

  if [ -x "$INSTALL_PYTHON" ]; then
    exec "$INSTALL_PYTHON" -mpre_commit "${ARGS[@]}"
  elif command -v pre-commit >/dev/null; then
    exec pre-commit "${ARGS[@]}"
  else
    echo '`pre-commit` not found.  Did you forget to activate your virtualenv?' 1>&2
    exit 1
  fi
fi

# If you want to allow non-ascii filenames set this variable to true.
allownonascii=$(git config hooks.allownonascii)

# Redirect output to stderr.
exec 1>&2

# Cross platform projects tend to avoid non-ascii filenames; prevent
# them from being added to the repository. We exploit the fact that the
# printable range starts at the space character and ends with tilde.
if [ "$allownonascii" != "true" ] &&
  # Note that the use of brackets around a tr range is ok here, (it's
  # even required, for portability to Solaris 10's /usr/bin/tr), since
  # the square bracket bytes happen to fall in the designated range.
  test $(git diff --cached --name-only --diff-filter=A -z $against |
    LC_ALL=C tr -d '[ -~]\0' | wc -c) != 0; then
  echo "Error: Attempt to add a non-ascii file name."
  echo
  echo "This can cause problems if you want to work"
  echo "with people on other platforms."
  echo
  echo "To be portable it is advisable to rename the file ..."
  echo
  echo "If you know what you are doing you can disable this"
  echo "check using:"
  echo
  echo "  git config hooks.allownonascii true"
  echo
  exit 1
fi

# If there are whitespace errors, print the offending file names and fail.
exec git diff-index --check --cached $against --