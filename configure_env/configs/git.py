import os
from typing import Final, List

from overrides import override

from configure_env.env_files_abc import EnvFileDst, EnvFilesABC, EnvFilesTargets, EnvFileType
from configure_env.utils.constants import CONFIGS_DIR, HOME_DIR
from configure_env.utils.logger import get_logger

CONFIGS_DIR_GIT: Final[str] = os.path.join(CONFIGS_DIR, 'git')
HOOKS_DIR: Final[str] = os.path.join(CONFIGS_DIR_GIT, 'templates', 'hooks')

logger = get_logger()

# pylint: disable=missing-class-docstring,missing-function-docstring


class GitFiles(EnvFilesABC):

    @staticmethod
    @override
    def dirs_to_create() -> List[str]:
        return [os.path.join(HOME_DIR, d) for d in (os.path.join('git', 'templates', 'hooks'),)]

    @staticmethod
    @override
    def dirs_to_link() -> EnvFilesTargets:
        return []

    @staticmethod
    @override
    def files_to_link() -> EnvFilesTargets:
        return [
            EnvFileDst(
                src=os.path.join(HOOKS_DIR, 'pre-commit.sh'), dst=os.path.join(HOME_DIR, 'git', 'templates', 'hooks', 'pre-commit'),
                type_=EnvFileType.FILE_LINK),
        ]

    @staticmethod
    @override
    def files_to_copy() -> EnvFilesTargets:
        return []
