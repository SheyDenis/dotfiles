import os
from typing import Final, Iterable, Tuple

from configure_env.utils.constants import HOME_DIR
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


def create_local_dirs(dry_run: bool) -> bool:
    logger.info('Creating env directories')
    dirs_to_create: Final[Iterable[str, ...]] = (
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
    pass  # TODO


def execute(dry_run: bool) -> bool:
    return create_local_dirs(dry_run) and link_dotfiles(dry_run) and copy_dotfiles(dry_run)
