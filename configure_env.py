#!/usr/bin/python3

import os
import sys
from argparse import Namespace
from collections import defaultdict
from typing import List, Tuple, Type

from configure_env.configs.git import GitFiles
from configure_env.configs.vscode import VsCodeFiles
from configure_env.dotfiles.dotfiles import DotfilesFiles
from configure_env.env_files_abc import EnvFilesABC, EnvFilesTargets, EnvFileType
from configure_env.utils.argparse import get_base_parser
from configure_env.utils.files_utils import copy_file, create_dir, link_dir, link_file
from configure_env.utils.logger import get_logger

logger = get_logger()

# pylint: disable=missing-function-docstring


def parse_arguments() -> Namespace:
    base_parse = get_base_parser()

    return base_parse.parse_args()


def create_dirs(dirs_to_create: List[str], dry_run: bool) -> bool:
    logger.info('Creating directories')
    success: bool = True
    for dir_ in dirs_to_create:
        success &= create_dir(dir_, dry_run=dry_run)

    return success


def link_dirs(dirs_to_link: EnvFilesTargets, dry_run: bool) -> bool:
    logger.info('Linking directories')
    success: bool = True
    for dir_ in dirs_to_link:
        success &= link_dir(dir_.src, dir_.dst, dry_run=dry_run)

    return success


def link_files(files_to_link: EnvFilesTargets, dry_run: bool) -> bool:
    logger.info('Linking files')
    success: bool = True
    for file_ in files_to_link:
        success &= link_file(file_.src, file_.dst, dry_run=dry_run)

    return success


def copy_files(files_to_copy: EnvFilesTargets, dry_run: bool) -> bool:
    logger.info('Copying files')
    success: bool = True
    for file_ in files_to_copy:
        success &= copy_file(file_.src, file_.dst, dry_run=dry_run)

    return success


def get_dirs_to_create(*env_files: Type[EnvFilesABC]) -> List[str]:
    dirs_to_create: List[str] = []

    for env_file in env_files:
        dirs_to_create.extend(env_file.dirs_to_create())
    return dirs_to_create


def get_dirs_to_link(*env_files: Type[EnvFilesABC]) -> EnvFilesTargets:
    dirs_to_link: EnvFilesTargets = []

    for env_file in env_files:
        dirs_to_link.extend(env_file.dirs_to_link())
    return dirs_to_link


def get_files_to_link(*env_files: Type[EnvFilesABC]) -> EnvFilesTargets:
    files_to_link: EnvFilesTargets = []

    for env_file in env_files:
        files_to_link.extend(env_file.files_to_link())
    return files_to_link


def get_files_to_copy(*env_files: Type[EnvFilesABC]) -> EnvFilesTargets:
    files_to_copy: EnvFilesTargets = []

    for env_file in env_files:
        files_to_copy.extend(env_file.files_to_copy())
    return files_to_copy


def has_conflicts(dirs_to_create: List[str], dirs_to_link: EnvFilesTargets, files_to_link: EnvFilesTargets,
                  files_to_copy: EnvFilesTargets) -> bool:
    """Check if any file or directory would overwrite each other."""
    conflicts = defaultdict(list)
    res: bool = False

    for env_file_target in (*dirs_to_link, *files_to_link, *files_to_copy):
        conflicts[env_file_target.dst].append({
            'src': env_file_target.src,
            'type': env_file_target.type_.value
        })
        if env_file_target.dst in dirs_to_create:
            conflicts[env_file_target.dst].append({
                'src': env_file_target.dst,
                'type': EnvFileType.DIRECTORY.value
            })

    for k, v in conflicts.items():
        if len(v) > 1:
            res = True
            logger.error('Destination [%s] has conflicts:\n%s', k, '\n'.join(f'[{conflict["type"]}] {conflict["src"]}' for conflict in v))

    return res


def log_work(dirs_to_create: List[str], dirs_to_link: EnvFilesTargets, files_to_link: EnvFilesTargets,
             files_to_copy: EnvFilesTargets) -> None:
    """Print the expected work that should be done."""

    logger.debug('About to create directories:\n%s', '\n'.join(d for d in dirs_to_create))
    logger.debug('About to link directories:\n%s', '\n'.join(f'{d.dst} -> {d.src}' for d in dirs_to_link))
    logger.debug('About to link files:\n%s', '\n'.join(f'{d.dst} -> {d.src}' for d in files_to_link))
    logger.debug('About to copy files:\n%s', '\n'.join(f'{d.dst} -> {d.src}' for d in files_to_copy))
    logger.info('About to create [%d] directories, link [%d] directories and [%d] files, copy [%d] files', len(dirs_to_create),
                len(dirs_to_link), len(files_to_link), len(files_to_copy))


def main() -> int:
    args = parse_arguments()
    env_files_classes: Tuple[Type[EnvFilesABC], ...] = (
        DotfilesFiles,
        GitFiles,
        VsCodeFiles,
    )

    dirs_to_create = get_dirs_to_create(*env_files_classes)
    dirs_to_link = get_dirs_to_link(*env_files_classes)
    files_to_link = get_files_to_link(*env_files_classes)
    files_to_copy = get_files_to_copy(*env_files_classes)

    if has_conflicts(dirs_to_create, dirs_to_link, files_to_link, files_to_copy):
        logger.error('Found path conflicts, aborting')
        return 1

    log_work(dirs_to_create, dirs_to_link, files_to_link, files_to_copy)

    if not create_dirs(dirs_to_create, dry_run=args.dry_run):
        logger.error('Failed to create directories')
        return 1
    if not link_dirs(dirs_to_link, dry_run=args.dry_run):
        logger.error('Failed to link directories')
        return 1
    if not link_files(files_to_link, dry_run=args.dry_run):
        logger.error('Failed to link files')
        return 1
    if not copy_files(files_to_copy, dry_run=args.dry_run):
        logger.error('Failed to copy files')
        return 1

    return os.EX_OK


if __name__ == '__main__':
    sys.exit(main())
