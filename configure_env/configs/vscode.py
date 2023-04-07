import os
import platform
from typing import Final, Iterable, Tuple

from configure_env.utils.constants import CONFIGS_DIR, HOME_DIR
from configure_env.utils.files_utils import copy_file, create_dir, link_file
from configure_env.utils.logger import get_logger

# pylint: disable=missing-function-docstring


def __get_platform_config_path() -> str:
    if platform.system().lower() == 'linux':
        return os.path.join(HOME_DIR, '.config/Code - OSS/User')
    return os.path.join(HOME_DIR, 'Library/Application Support/Code/User')


CONFIGS_DIR_VSCODE: Final[str] = os.path.join(CONFIGS_DIR, 'vscode')
SNIPPETS_DIR: Final[str] = os.path.join(CONFIGS_DIR_VSCODE, 'snippets')
PLATFORM_CONFIG_PATH_VSCODE: Final[str] = __get_platform_config_path()
SNIPPETS_DIR_PATH: Final[str] = os.path.join(PLATFORM_CONFIG_PATH_VSCODE, 'snippets')

logger = get_logger()


def create_dirs(dry_run: bool) -> bool:
    logger.info('Creating config directories')
    dirs_to_create: Final[Iterable[str]] = (os.path.join(PLATFORM_CONFIG_PATH_VSCODE, 'snippets'),)

    success: bool = True
    for dir_ in dirs_to_create:
        success &= create_dir(dir_, dry_run=dry_run)

    return success


def copy_configs(dry_run: bool) -> bool:
    logger.info('Copying VSCode configs')
    files_to_copy: Final[Iterable[Tuple[str, str]]] = tuple()

    success: bool = True
    for src, dst in files_to_copy:
        success &= copy_file(src, dst, dry_run=dry_run)

    return success


def link_configs(dry_run: bool) -> bool:
    logger.info('Linking VSCode configs')
    links_to_create: Final[Iterable[Tuple[str, str]]] = (
        # Configs
        (os.path.join(CONFIGS_DIR_VSCODE, 'tasks.json'), os.path.join(PLATFORM_CONFIG_PATH_VSCODE, 'tasks.json')),
        # Snippets
        *((os.path.join(SNIPPETS_DIR, snippet.name), os.path.join(SNIPPETS_DIR_PATH, f'dotfiles_{snippet.name}'))
          for snippet in os.scandir(SNIPPETS_DIR)))

    success: bool = True
    for src, dst in links_to_create:
        success &= link_file(src, dst, dry_run=dry_run)

    return success


def execute(dry_run: bool) -> bool:
    return create_dirs(dry_run) and copy_configs(dry_run) and link_configs(dry_run)
