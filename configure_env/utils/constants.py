import os.path
from typing import Final

# Script execution constants
LOGGER_DEBUG_ARG: Final[str] = '--logger-level-debug'

# Path constants
HOME_DIR: Final[str] = os.path.expanduser('~')
PROJECT_BASE_DIR: Final[str] = os.path.dirname(os.path.dirname(os.path.dirname(os.path.realpath(__file__))))
CONFIGS_DIR: Final[str] = os.path.join(PROJECT_BASE_DIR, 'configs')
DOTFILES_DIR: Final[str] = os.path.join(PROJECT_BASE_DIR, 'dotfiles')
