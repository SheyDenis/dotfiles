from configure_env.utils.logger import get_logger

logger = get_logger()


def copy_snippets(dry_run: bool) -> bool:
    logger.info('Copying VSCode snippets')
    pass  # TODO


def execute(dry_run: bool) -> bool:
    return copy_snippets(dry_run)
