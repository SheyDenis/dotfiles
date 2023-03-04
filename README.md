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

- [ ] backup_dotfiles.py
  - [ ] Refactor.
  - [ ] Auto increment version on merge to master.
- [ ] Add `configure_env.sh` script.
  - [ ] Refactor and split to smaller parts.
  - [ ] Add usage.
  - [ ] Add script header.
- [ ] pre-commit.sh
  - [ ] Refactor so uses pre-commit repo.
- [ ] Add git hooks to dotfiles repo.
- [ ] vscode
  - [ ] Auto enable pipenv env in terminal.
  - [ ] Show VSC gutter colors for staged files too.
  - [ ] Perform "external tools" like actions on file.
  - [ ] VSCode spellcheck.
  - [ ] Keymap config.
  - [ ] List of extensions to install.
  - [ ] markdown formatter.
  - [ ] Make vscode snippets use nested snippets.
