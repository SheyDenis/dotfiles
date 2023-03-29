import filecmp
import os
import shutil
from typing import Callable, Dict, Final, Iterable, Optional, Tuple, cast

from mypy_extensions import NamedArg

from configure_env.utils.constants import DOTFILES_DIR, HOME_DIR
from configure_env.utils.logger import get_logger

logger = get_logger()


def _create_local_dir(dir_: str, *, dry_run: bool) -> bool:
    if os.path.isdir(dir_):
        logger.info('Not creating directory [%s], already exists', dir_)
        return True
    try:
        if not dry_run:
            os.makedirs(dir_, exist_ok=True)
        logger.info('Created dir [%s]', dir_)
        return True
    except (FileExistsError, NotADirectoryError):
        logger.error('Cannot create [%s], is it a directory?', dir_)
    except PermissionError:
        logger.error('No permissions to create [%s]', dir_)
    return False


def _link_dotfiles(src: str, dst: str, *, dry_run: bool) -> bool:
    if os.path.islink(dst):
        if os.path.realpath(dst) != src:
            logger.error('Link [%s] links to [%s] instead of [%s]', dst, os.path.realpath(dst), src)
            return False
        logger.info('Not creating link [%s], already exists', dst)
        return True

    try:
        if not dry_run:
            os.symlink(src, dst)
        return True
    except PermissionError:
        logger.error('No permissions to link [%s] to [%s]', src, dst)
    except NotADirectoryError:
        logger.error('Cannot create link [%s], is the path a file?', dst)

    return False


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
    dotfile_dst = cast(str, dotfile_dst)

    if os.path.isdir(dotfile_dst) or os.path.islink(dotfile_dst):
        logger.error('Destination file [%s] for [%s] is a [isdir=%s][islink=%s]', dotfile_dst, dotfile.path, os.path.isdir(dotfile_dst),
                     os.path.islink(dotfile_dst))
        return False

    if os.path.exists(dotfile_dst):
        if filecmp.cmp(dotfile.path, dotfile_dst):
            logger.info('Files [%s] and [%s] match, continuing', dotfile.path, dotfile_dst)
            return True
        logger.warning('Files [%s] and [%s] differ', dotfile.path, dotfile_dst)
        return False

    logger.info('Copying file [%s] to [%s]', dotfile.path, dotfile_dst)
    if not dry_run:
        shutil.copyfile(dotfile.path, dotfile_dst, follow_symlinks=False)

    return True


def _link_dotfile(dotfile: os.DirEntry, *, dry_run: bool) -> bool:
    logger.info('Linking dotfile [%s]', dotfile.path)

    dotfile_dst: Optional[str] = _get_dotfile_copy_dst(dotfile)
    if not dotfile_dst:
        return False
    dotfile_dst = cast(str, dotfile_dst)

    if os.path.exists(dotfile_dst) and not os.path.islink(dotfile_dst):
        logger.error('Destination file [%s] for [%s] is a [isdir=%s][isfile=%s]', dotfile_dst, dotfile.path, os.path.isdir(dotfile_dst),
                     os.path.isfile(dotfile_dst))
        return False

    if os.path.exists(dotfile_dst):
        link_dst: str = dotfile_dst
        while True:
            try:
                link_dst = os.readlink(link_dst)
                continue
            except OSError:
                pass
            break
        if link_dst == dotfile.path:
            logger.warning('Destination file [%s] for [%s] doesn\'t exist, remove the link and try again', dotfile_dst, dotfile.path)
            return False

    logger.info('Creating link [%s] to [%s]', dotfile_dst, dotfile.path)
    if not dry_run:
        os.symlink(dotfile.path, dotfile_dst)
    return True


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
        success &= _create_local_dir(dir_, dry_run=dry_run)

    return success


def link_dotfiles(dry_run: bool) -> bool:
    logger.info('Linking env aliases and functions')
    links_to_create: Final[Iterable[Tuple[str, str]]] = ((os.path.join(
        os.path.dirname(os.path.dirname(os.path.realpath(__file__))),
        d,
    ), os.path.join(HOME_DIR, '.local', d, f'dotfiles_{d}')) for d in (
        'aliases',
        'functions',
    ))

    success: bool = True
    for src, dst in links_to_create:
        success &= _link_dotfiles(src, dst, dry_run=dry_run)

    return success


def copy_dotfiles(dry_run: bool) -> bool:
    logger.info('Copying dotfiles')
    dotfiles_to_link: Final[Tuple[str, ...]] = ('gitignore',)

    success: bool = True
    with os.scandir(DOTFILES_DIR) as itr:
        dotfile: os.DirEntry
        for dotfile in itr:
            func: Callable[[os.DirEntry, NamedArg(bool, 'dry_run')],
                           bool] = _link_dotfile if dotfile.name in dotfiles_to_link else _copy_dotfile
            success &= func(dotfile, dry_run=dry_run)

    return success


def execute(dry_run: bool) -> bool:
    return create_local_dirs(dry_run) and link_dotfiles(dry_run) and copy_dotfiles(dry_run)
