from smartfast.tools.kspec_coverage.analysis import run_analysis
from smartfast import Smartfast


def kspec_coverage(args):

    contract = args.contract
    kspec = args.kspec

    smartfast = Smartfast(contract, **vars(args))

    # Run the analysis on the Klab specs
    run_analysis(args, smartfast, kspec)
