from argparse import ArgumentParser

from .constants import LOGGER_DEBUG_ARG


def get_base_parser(**kwargs) -> ArgumentParser:
    """Get the base parser with the common arguments."""
    parser = ArgumentParser(**kwargs)

    parser.add_argument(LOGGER_DEBUG_ARG, action='store_true', help='Set logger to debug level')

    dry_run_group = parser.add_mutually_exclusive_group()
    dry_run_group.add_argument('--dry-run', action='store_true')
    dry_run_group.add_argument('--no-dry-run', action='store_false')

    return parser
