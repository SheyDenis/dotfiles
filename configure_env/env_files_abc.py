from abc import ABC, abstractmethod
from enum import Enum
from typing import List, NamedTuple

# pylint: disable=missing-class-docstring,missing-function-docstring


class EnvFileType(str, Enum):
    DIRECTORY = 'Directory'
    DIRECTORY_LINK = 'DirectoryLink'
    FILE = 'File'
    FILE_LINK = 'FileLink'
    LINK = 'Link'


class EnvFileDst(NamedTuple):
    src: str
    dst: str
    type_: EnvFileType


EnvFilesTargets = List[EnvFileDst]


class EnvFilesABC(ABC):

    @staticmethod
    @abstractmethod
    def dirs_to_create() -> List[str]:
        pass

    @staticmethod
    @abstractmethod
    def dirs_to_link() -> EnvFilesTargets:
        pass

    @staticmethod
    @abstractmethod
    def files_to_link() -> EnvFilesTargets:
        pass

    @staticmethod
    @abstractmethod
    def files_to_copy() -> EnvFilesTargets:
        pass
