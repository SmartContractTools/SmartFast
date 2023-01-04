from smartfast.detectors.abstract_detector import AbstractDetector, DetectorClassification


class Example(AbstractDetector):  # pylint: disable=too-few-public-methods
    """
    Documentation
    """

    ARGUMENT = "mydetector"  # smartfast will launch the detector with smartfast.py --mydetector
    HELP = "Help printed by smartfast"
    IMPACT = DetectorClassification.HIGH
    CONFIDENCE = DetectorClassification.HIGH

    WIKI = ""

    WIKI_TITLE = ""
    WIKI_DESCRIPTION = ""
    WIKI_EXPLOIT_SCENARIO = ""
    WIKI_RECOMMENDATION = ""

    def _detect(self):

        info = "This is an example!"

        json = self.generate_result(info)

        return [json]
