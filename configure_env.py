#!/usr/bin/python3

import os
import sys
from argparse import Namespace
from typing import Callable, Final, Iterable

from configure_env.configs.vscode import execute as vscode_execute
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
        vscode_execute,
    )
    for func in funcs:
        if not func(args.dry_run):
            return 1

    return os.EX_OK


if __name__ == '__main__':
    sys.exit(main())
