#!/usr/bin/python3

import os
import sys
from argparse import Namespace
from typing import Callable, Final, Iterable

from configure_env.configs.git import execute as git_configs_execute
from configure_env.configs.vscode import execute as vscode_configs_execute
from configure_env.dotfiles.dotfiles import execute as dotfiles_execute
from configure_env.utils.argparse import get_base_parser
from configure_env.utils.logger import get_logger

logger = get_logger()


def parse_arguments() -> Namespace:
    base_parse = get_base_parser()

    return base_parse.parse_args()


def main() -> int:
    args = parse_arguments()
    funcs: Final[Iterable[Callable[[bool], bool]]] = (
        dotfiles_execute,
        git_configs_execute,
        vscode_configs_execute,
    )

    success: bool = True
    for func in funcs:
        success &= func(args.dry_run)

    return os.EX_OK if success else 1


if __name__ == '__main__':
    sys.exit(main())
