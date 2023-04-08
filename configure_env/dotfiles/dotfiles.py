import os
from typing import Final, List, Tuple

from overrides import override

from configure_env.env_files_abc import EnvFileDst, EnvFilesABC, EnvFilesTargets, EnvFileType
from configure_env.utils.constants import DOTFILES_DIR, HOME_DIR, PROJECT_BASE_DIR
from configure_env.utils.logger import get_logger

logger = get_logger()

# pylint: disable=missing-class-docstring,missing-function-docstring


class DotfilesFiles(EnvFilesABC):

    @staticmethod
    @override
    def dirs_to_create() -> List[str]:
        return [os.path.join(HOME_DIR, '.local', d) for d in (
            'aliases',
            'bin',
            'functions',
        )]

    @staticmethod
    @override
    def dirs_to_link() -> EnvFilesTargets:
        return [
            EnvFileDst(
                src=os.path.join(PROJECT_BASE_DIR, d), dst=os.path.join(HOME_DIR, '.local', d, f'dotfiles_{d}'),
                type_=EnvFileType.DIRECTORY_LINK) for d in (
                    'aliases',
                    'functions',
                )
        ]

    @staticmethod
    @override
    def files_to_link() -> EnvFilesTargets:
        dotfiles_to_link: Final[Tuple[str, ...]] = ('gitignore',)

        return [
            EnvFileDst(src=os.path.join(DOTFILES_DIR, f), dst=os.path.join(HOME_DIR, f'.{f}'), type_=EnvFileType.FILE_LINK)
            for f in dotfiles_to_link
        ]

    @staticmethod
    @override
    def files_to_copy() -> EnvFilesTargets:
        dotfiles_to_link: Final[List[str]] = [f.src for f in DotfilesFiles.files_to_link()]

        res: EnvFilesTargets = []
        with os.scandir(DOTFILES_DIR) as itr:
            dotfile: os.DirEntry
            for dotfile in itr:
                if dotfile.path in dotfiles_to_link:
                    continue

                res.append(EnvFileDst(src=dotfile.path, dst=os.path.join(HOME_DIR, f'.{dotfile.name}'), type_=EnvFileType.FILE))

        return res
