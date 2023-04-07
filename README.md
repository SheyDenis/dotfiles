## dotfiles repo

Personal repo for dotfiles and general rc files.

## File Structure

### aliases

Files containing shell aliases.

### configs

### dotfiles

General dotfiles that will be copied over other dotfiles.
Each file MUST have the following header at the top of the file:

```
#
# <path_where_to_copy_the_file_to>
#
```

For example:

```
#
# ~/.bashrc
#
```

### functions

Files containing shell functions.

### TODO

- [x] Create a template repo with `master` branch and default settings and workflow / hooks.
- [>] backup_dotfiles.py
    - [ ] Refactor.
    - [x] Auto increment version on merge to master.
    - [?] Delete.
- [>] Add `configure_env.sh` script.
    - [x] Refactor and split to smaller parts.
    - [x] Rewrite in python.
    - [-] Add usage.
    - [-] Add script header.
    - [>] Implement git configs.
    - [ ] Add caller to `files_utils.py` logger.
    - [ ] Delete.
- [ ] Add JetBrains settings.
- [ ] Refactor `pre-commit.sh` to check for a local `.personal-pre-commit-config.yml` instead of a global one.
