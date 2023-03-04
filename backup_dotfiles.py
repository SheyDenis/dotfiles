#!/usr/bin/env python3

# title           :backup_dotfiles.py
# description     :Utility script for backing up dotfiles and other files.
# author          :Denis Sheyer
# ===============================================================================

import filecmp
import logging
import os
import pathlib
import shutil
import sys
from argparse import ArgumentParser, Namespace
from typing import Final, NamedTuple, Optional, Tuple

VERSION = '12023-02-17'
BACKUP_DEST = ''
DRY_RUN_DEFAULT: Final[bool] = False
MAX_FILE_SIZE_MB_DEFAULT: Final[float] = 20


# pylint: disable=missing-class-docstring,missing-function-docstring

class BackupFile(NamedTuple):
    src: str
    dst: Optional[str] = None


BACKUP_FILES: Final[Tuple[BackupFile, ...]] = (
    BackupFile('.aliases', 'dotfiles'),
    BackupFile('.functions', 'dotfiles'),
    BackupFile('.gitconfig', 'dotfiles'),
    BackupFile('.gitignore', 'dotfiles'),
    BackupFile('.local/aliases', 'dotfiles/aliases'),
    BackupFile('.local/scripts/backup_dotfiles.py', 'scripts'),
    BackupFile('git/scratches', 'scratches'),
    BackupFile('git/templates/hooks/pre-commit.sh', 'git'),
)


def init_logging(log_level: int = logging.DEBUG) -> None:
    logging.basicConfig(level=log_level)


def init_argparse() -> ArgumentParser:
    parser = ArgumentParser(prog='Utility script for backing up dotfiles and other files.')
    parser.add_argument('-v', '--version', action='store_true')
    parser.add_argument('--log-level', type=int, choices=[logging.CRITICAL, logging.ERROR, logging.WARNING,
                                                          logging.INFO, logging.DEBUG], default=logging.DEBUG)
    parser.add_argument('-n', '--dry-run', action='store_true', help='Dry run, only print what would have happened.')
    parser.add_argument('--continue-on-error', action='store_true', help='Continue backup even if some files fail.')
    parser.add_argument('--max-file-size-mb', type=float, help='Max file size in MB to copy, skip files larger.',
                        default=MAX_FILE_SIZE_MB_DEFAULT)
    parser.add_argument('--force', action='store_true', help='Force backup even if not different.')

    return parser


def print_version() -> None:
    print(f'Version: {VERSION}')


def create_dir(dst: str, dry_run: bool = DRY_RUN_DEFAULT) -> bool:
    if os.path.exists(dst.rstrip('/')) and not os.path.isdir(dst.rstrip('/')):
        logging.error('Dir exists but it not a directory [%s], aborting...', dst)
        return False

    if not os.path.exists(dst.rstrip('/')):
        logging.info('Missing dir [%s], creating...', dst)
        try:
            if not dry_run:
                pathlib.Path(dst).mkdir(parents=True, exist_ok=True)
        except (NotADirectoryError, PermissionError) as ex:
            logging.error('Failed to create dir [%s] - [%s]', dst, str(ex))
            return False

    return True


def init_backup_dir(dry_run: bool = DRY_RUN_DEFAULT) -> bool:
    return create_dir(BACKUP_DEST, dry_run=dry_run)


def get_dst(backup_file: BackupFile) -> str:
    if backup_file.dst is not None:
        dst = backup_file.dst
        if not dst.startswith(BACKUP_DEST.rstrip('/')):
            dst = os.path.join(BACKUP_DEST, backup_file.dst)
        if os.path.split(backup_file.src)[1] and dst.rstrip('/').endswith(os.path.split(backup_file.src)[1]):
            return dst
        return os.path.join(dst, os.path.split(backup_file.src)[1])

    dst_parts = os.path.split(backup_file.src)
    if dst_parts[0]:
        return os.path.join(BACKUP_DEST, os.path.split(dst_parts[0])[1], dst_parts[1])
    return os.path.join(BACKUP_DEST, dst_parts[1])


def diff_file(src: str, dst: str) -> bool:
    if not os.path.exists(dst):
        return True
    return not filecmp.cmp(src, dst)


def diff_dir(src: str, dst: str) -> bool:
    for filename in os.listdir(src):
        backup_file = BackupFile(os.path.join(src, filename), dst)
        file_src = backup_file.src
        file_dst = get_dst(backup_file)
        if os.path.isdir(file_src):
            if diff_dir(file_src, file_dst):
                return True
        else:
            if diff_file(file_src, file_dst):
                return True
    return False

def get_file_size_mb(src: str) -> float:
    return os.stat(src).st_size / (1024 * 1024)

def sync_file(src: str, dst: str, dry_run: bool = DRY_RUN_DEFAULT, force: bool = False, max_file_size_mb:
              float = MAX_FILE_SIZE_MB_DEFAULT) -> bool:

    if not force and not diff_file(src, dst):
        logging.info('File [%s] is up to date', src)
        return True

    if get_file_size_mb(src) > max_file_size_mb:
        logging.warning('File [%s] is too large [%.1f / %.1f]MB', src, get_file_size_mb(src), max_file_size_mb)
        if not force:
            return False
    logging.debug('Copying [%s] to [%s]', src, dst)

    if not os.path.exists(os.path.split(dst)[0]):
        logging.info('Missing backup destination [%s]', os.path.split(dst)[0])
        if not create_dir(os.path.split(dst)[0], dry_run=dry_run):
            return False

    try:
        if not dry_run:
            shutil.copy2(src, dst, follow_symlinks=False)
    except OSError as ex:
        logging.error('Failed to copy [%s] to [%s] - [%s]', src, dst, str(ex))
        return False
    return True


def sync_dir(src: str, dst: str, *, dry_run: bool = DRY_RUN_DEFAULT, continue_on_error: bool = False,
             force: bool = False, max_file_size_mb: float = MAX_FILE_SIZE_MB_DEFAULT) -> bool:
    for filename in os.listdir(src):
        backup_file = BackupFile(os.path.join(src, filename), dst)
        file_src = backup_file.src
        file_dst = get_dst(backup_file)
        success: bool = True
        last_handled_is_dir: bool = False
        if os.path.isdir(file_src):
            last_handled_is_dir = True
            logging.info('Recursively syncing [%s]', file_src)
            success = sync_dir(file_src, file_dst, dry_run=dry_run, continue_on_error=continue_on_error, max_file_size_mb=max_file_size_mb)
        else:
            last_handled_is_dir = False
            success = sync_file(file_src, file_dst, dry_run=dry_run, force=force, max_file_size_mb=max_file_size_mb)

        if not (success or continue_on_error):
            logging.error('Failed to sync %s [%s]', 'dir' if last_handled_is_dir else 'file', file_src)
            return False

    return True


def main(args: Namespace) -> bool:
    success: bool = True
    for backup_file in BACKUP_FILES:
        src = backup_file.src
        dst = get_dst(backup_file)
        if not src.startswith('/'):
            src = os.path.join(os.path.expanduser('~'), backup_file.src)

        if not os.path.exists(src):
            logging.warning('Missing backup source [%s], skipping', src)
            success = False
            continue

        if os.path.isdir(src):
            logging.info('Syncing dir [%s]', src)
            if not sync_dir(src, dst, dry_run=args.dry_run, continue_on_error=args.continue_on_error,
                            max_file_size_mb=args.max_file_size_mb):
                logging.error('Failed to sync dir [%s]', src)
                success = False
                if not args.continue_on_error:
                    return False
        else:
            logging.info('Syncing file [%s]', src)
            if not sync_file(src, dst, dry_run=args.dry_run, force=args.force, max_file_size_mb=args.max_file_size_mb):
                logging.error('Failed to sync file [%s]', src)
                success = False
                if not args.continue_on_error:
                    return False

    return success


if __name__ == '__main__':
    args_: Namespace = init_argparse().parse_args()
    if args_.version:
        print_version()
        sys.exit(os.EX_OK)

    init_logging(args_.log_level)
    if not init_backup_dir(dry_run=args_.dry_run):
        sys.exit(os.EX_IOERR)

    logging.info('Using backup dir [%s]', BACKUP_DEST)
    if main(args_):
        logging.info('Finished backup to [%s]', BACKUP_DEST)
        sys.exit(os.EX_OK)
    else:
        logging.critical('Failed to backup to dir [%s]', BACKUP_DEST)
        sys.exit(1)
