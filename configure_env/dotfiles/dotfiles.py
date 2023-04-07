import os
from typing import Callable, Dict, Final, Iterable, Optional, Tuple, cast

from mypy_extensions import NamedArg

from configure_env.utils.constants import DOTFILES_DIR, HOME_DIR, PROJECT_BASE_DIR
from configure_env.utils.files_utils import copy_file, create_dir, link_dir, link_file
from configure_env.utils.logger import get_logger

logger = get_logger()


def _get_dotfile_copy_dst(dotfile: os.DirEntry) -> Optional[str]:
    dst_exceptions: Final[Dict[str, str]] = {
        'vimrc': '~/.vimrc',
    }
    if dotfile.name in dst_exceptions:
        return os.path.expanduser(dst_exceptions[dotfile.name])

    dotfile_dst: str
    with open(dotfile.path, 'r') as fh:
        dotfile_dst = os.path.expanduser(fh.readlines(2)[-1].lstrip('# ').rstrip('\n'))

    if not dotfile_dst or dotfile_dst.isspace():
        logger.error('Failed to get destination file for [%s]', dotfile.path)
        return None
    return dotfile_dst


def _copy_dotfile(dotfile: os.DirEntry, *, dry_run: bool) -> bool:
    logger.info('Copying dotfile [%s]', dotfile.path)
    dotfile_dst: Optional[str] = _get_dotfile_copy_dst(dotfile)
    if not dotfile_dst:
        return False

    return copy_file(dotfile.path, cast(str, dotfile_dst), dry_run=dry_run)


def _link_dotfile(dotfile: os.DirEntry, *, dry_run: bool) -> bool:
    logger.info('Linking dotfile [%s]', dotfile.path)

    dotfile_dst: Optional[str] = _get_dotfile_copy_dst(dotfile)
    if not dotfile_dst:
        return False
    return link_file(dotfile.path, cast(str, dotfile_dst), dry_run=dry_run)


def create_local_dirs(dry_run: bool) -> bool:
    logger.info('Creating env directories')
    dirs_to_create: Final[Iterable[str]] = (
        os.path.join(HOME_DIR, '.local', d) for d in (
            'aliases',
            'bin',
            'functions',
        ))

    success: bool = True
    for dir_ in dirs_to_create:
        success &= create_dir(dir_, dry_run=dry_run)

    return success


def link_dotfiles(dry_run: bool) -> bool:
    logger.info('Linking env aliases and functions')
    links_to_create: Final[Iterable[Tuple[str, str]]] = ((os.path.join(
        PROJECT_BASE_DIR,
        d,
    ), os.path.join(HOME_DIR, '.local', d, f'dotfiles_{d}')) for d in (
        'aliases',
        'functions',
    ))

    success: bool = True
    for src, dst in links_to_create:
        success &= link_dir(src, dst, dry_run=dry_run)

    return success


def copy_dotfiles(dry_run: bool) -> bool:
    logger.info('Copying dotfiles')
    dotfiles_to_link: Final[Tuple[str, ...]] = ('gitignore',)

    success: bool = True
    with os.scandir(DOTFILES_DIR) as itr:
        dotfile: os.DirEntry
        for dotfile in itr:
            func: Callable[[os.DirEntry, NamedArg(bool, 'dry_run')], bool]
            if dotfile.name in dotfiles_to_link:
                func = _link_dotfile
            else:
                func = _copy_dotfile
            success &= func(dotfile, dry_run=dry_run)

    return success


def execute(dry_run: bool) -> bool:
    return create_local_dirs(dry_run) and link_dotfiles(dry_run) and copy_dotfiles(dry_run)
