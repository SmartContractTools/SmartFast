from smartfast.detectors.abstract_detector import AbstractDetector, DetectorClassification


class Backdoor(AbstractDetector):
    """
    Detect function named backdoor
    """

    ARGUMENT = 'backdoor'  # smartfast will launch the detector with smartfast.py --mydetector
    HELP = 'Function named backdoor (detector example)'
    IMPACT = DetectorClassification.HIGH
    CONFIDENCE = DetectorClassification.EXACTLY


    WIKI = 'https://github.com/trailofbits/smartfast/wiki/Adding-a-new-detector'
    WIKI_TITLE = 'Backdoor example'
    WIKI_DESCRIPTION = 'Plugin example'
    WIKI_EXPLOIT_SCENARIO = '..'
    WIKI_RECOMMENDATION = '..'

    def _detect(self):
        results = []

        for contract in self.smartfast.contracts_derived:
            # Check if a function has 'backdoor' in its name
            for f in contract.functions:
                if 'backdoor' in f.name:
                    # Info to be printed
                    info = ['Backdoor function found in ', f, '\n']

                    # Add the result in result
                    res = self.generate_result(info)

                    results.append(res)

        return results
