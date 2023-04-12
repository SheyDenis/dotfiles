import os
import platform
from typing import Final, List

from overrides import override

from configure_env.env_files_abc import EnvFileDst, EnvFilesABC, EnvFilesTargets, EnvFileType
from configure_env.utils.constants import CONFIGS_DIR, HOME_DIR
from configure_env.utils.logger import get_logger

# pylint: disable=missing-class-docstring,missing-function-docstring

__USE_VSCODIUM: Final[bool] = True


def __get_platform_config_path() -> str:
    if platform.system().lower() == 'linux':
        if __USE_VSCODIUM:
            return os.path.join(HOME_DIR, '.config', 'VSCodium', 'User')
        return os.path.join(HOME_DIR, '.config', 'Code - OSS', 'User')
    return os.path.join(HOME_DIR, 'Library', 'Application Support', 'Code', 'User')


CONFIGS_DIR_VSCODE: Final[str] = os.path.join(CONFIGS_DIR, 'vscode')
SNIPPETS_DIR: Final[str] = os.path.join(CONFIGS_DIR_VSCODE, 'snippets')
PLATFORM_CONFIG_PATH_VSCODE: Final[str] = __get_platform_config_path()
SNIPPETS_DIR_PATH: Final[str] = os.path.join(PLATFORM_CONFIG_PATH_VSCODE, 'snippets')

logger = get_logger()


class VsCodeFiles(EnvFilesABC):

    @staticmethod
    @override
    def dirs_to_create() -> List[str]:
        return [os.path.join(PLATFORM_CONFIG_PATH_VSCODE, 'snippets')]

    @staticmethod
    @override
    def dirs_to_link() -> EnvFilesTargets:
        return []

    @staticmethod
    @override
    def files_to_link() -> EnvFilesTargets:
        res: EnvFilesTargets = []

        # Configs
        res.extend(
            EnvFileDst(
                src=os.path.join(CONFIGS_DIR_VSCODE, f), dst=os.path.join(PLATFORM_CONFIG_PATH_VSCODE, f), type_=EnvFileType.FILE_LINK)
            for f in (
                'settings.json',
                'tasks.json',
            ))

        # Snippets
        res.extend(
            EnvFileDst(
                src=os.path.join(SNIPPETS_DIR, snippet.name), dst=os.path.join(SNIPPETS_DIR_PATH, f'dotfiles_{snippet.name}'),
                type_=EnvFileType.FILE_LINK) for snippet in os.scandir(SNIPPETS_DIR))
        return res

    @staticmethod
    @override
    def files_to_copy() -> EnvFilesTargets:
        return []
