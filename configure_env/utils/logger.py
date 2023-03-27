import logging
import sys
from typing import Final, Optional

from .constants import LOGGER_DEBUG_ARG

__LOGGER_SETUP: bool = False
__LOGGER: logging.Logger


def setup_logger(log_level: Optional[int] = None) -> logging.Logger:
    log_format: Final[str] = '[%(asctime)s][%(levelname)-8s][%(funcName)s:%(lineno)d] %(message)s'
    if log_level is None:
        log_level = logging.DEBUG if LOGGER_DEBUG_ARG in sys.argv else logging.INFO

    logging.basicConfig(format=log_format, datefmt='%H:%M:%S %d/%m/%Y', level=log_level)

    return logging.getLogger()


def get_logger():
    global __LOGGER_SETUP
    global __LOGGER

    if not __LOGGER_SETUP:
        __LOGGER_SETUP = True
        __LOGGER = setup_logger()

    return __LOGGER
