import argparse
import logging
from crytic_compile import cryticparser
from smartfast import Smartfast

logging.basicConfig()
logging.getLogger("Smartfast").setLevel(logging.INFO)

logger = logging.getLogger("Smartfast-demo")


def parse_args():
    """
    Parse the underlying arguments for the program.
    :return: Returns the arguments for the program.
    """
    parser = argparse.ArgumentParser(description="Demo", usage="smartfast-demo filename")

    parser.add_argument(
        "filename", help="The filename of the contract or truffle directory to analyze."
    )

    # Add default arguments from crytic-compile
    cryticparser.init(parser)

    return parser.parse_args()


def main():
    args = parse_args()

    # Perform smartfast analysis on the given filename
    _smartfast = Smartfast(args.filename, **vars(args))

    logger.info("Analysis done!")


if __name__ == "__main__":
    main()
