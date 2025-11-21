#!/bin/bash

if git rev-parse --verify HEAD >/dev/null 2>&1; then
  against=HEAD
else
  # Initial commit: diff against an empty tree object
  against=4b825dc642cb6eb9a060e54bf8d69288fbee4904
fi

REPO_ROOT="$(git rev-parse --show-toplevel)"

if [[ -f "${REPO_ROOT}/.env" ]]; then
  source "${REPO_ROOT}/.env"
fi
HERE="$(cd "$(dirname "$0")" && pwd)"
INSTALL_PYTHON="${REPO_ROOT}/.venv/bin/python"

declare -a pre_commit_configs=(
  "${REPO_ROOT}/.pre-commit-config.yaml"         # pre-commit framework hooks.
  "${REPO_ROOT}/.personal-pre-commit-config.yml" # Personal repo specific pre-commit hooks.
  "${HOME}/git/pre-commit-config.yaml"           # Global pre-commit hooks.
)
if [[ -f "$(git rev-parse --show-toplevel)/.env" ]]; then
  # Source .env file if it exists, so we can add pre-commit env vars there. (e.g. SKIP=hook-name)
  echo "Sourcing $(git rev-parse --show-toplevel)/.env"
  . "$(git rev-parse --show-toplevel)/.env"
fi
for pre_commit_config_file in ${pre_commit_configs[*]}; do
  if [[ -f "${pre_commit_config_file}" ]]; then
    ARGS=(hook-impl "--config=${pre_commit_config_file}" "--hook-type=pre-commit" --hook-dir "$HERE" -- "$@")

    pre_commit_rc=1
    if [ -x "$INSTALL_PYTHON" ]; then
      "$INSTALL_PYTHON" -mpre_commit "${ARGS[@]}"
      pre_commit_rc=${?}
    elif command -v pre-commit >/dev/null; then
      pre-commit "${ARGS[@]}"
      pre_commit_rc=${?}
    else
      echo '`pre-commit` not found!' 1>&2
      exit 1
    fi

    if [[ ${pre_commit_rc} != 0 ]]; then
      echo "pre-commit failed with config file [${pre_commit_config_file}]" 1>&2
      exit ${pre_commit_rc}
    fi

  fi
done

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
