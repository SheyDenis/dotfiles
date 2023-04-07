import filecmp
import os
import shutil

from configure_env.utils.logger import get_logger

logger = get_logger()  # TODO - Add caller


def create_dir(dir_: str, *, dry_run: bool) -> bool:
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


def link_dir(src: str, dst: str, *, dry_run: bool) -> bool:
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


def copy_file(src: str, dst: str, *, dry_run: bool) -> bool:
    if os.path.isdir(dst) or os.path.islink(dst):
        logger.error('Destination file [%s] for [%s] is a [isdir=%s][islink=%s]', dst, src, os.path.isdir(dst), os.path.islink(dst))
        return False

    if os.path.exists(dst):
        if filecmp.cmp(src, dst):
            logger.info('Files [%s] and [%s] match, continuing', src, dst)
            return True
        logger.warning('Files [%s] and [%s] differ', src, dst)
        return False

    logger.info('Copying file [%s] to [%s]', src, dst)
    if not dry_run:
        shutil.copyfile(src, dst, follow_symlinks=False)

    return True


def link_file(src: str, dst: str, *, dry_run: bool) -> bool:
    if os.path.exists(dst) and not os.path.islink(dst):
        logger.error('Destination file [%s] for [%s] is a [isdir=%s][isfile=%s]', dst, src, os.path.isdir(dst), os.path.isfile(dst))
        return False

    if os.path.exists(dst):
        link_dst: str = dst
        while True:
            try:
                link_dst = os.readlink(link_dst)
                continue
            except OSError:
                pass
            break
        if link_dst == src:
            logger.warning('Destination file [%s] for [%s] doesn\'t exist, remove the link and try again', dst, src)
            return False

    logger.info('Creating link [%s] to [%s]', dst, src)
    if not dry_run:
        os.symlink(src, dst)
    return True
