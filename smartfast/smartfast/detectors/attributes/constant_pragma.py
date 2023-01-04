"""
    Check that the same pragma is used in all the files
"""

from smartfast.detectors.abstract_detector import AbstractDetector, DetectorClassification
from smartfast.formatters.attributes.constant_pragma import custom_format as format


class ConstantPragma(AbstractDetector):
    """
    Check that the same pragma is used in all the files
    """

    ARGUMENT = 'pragma'
    HELP = 'If different pragma directives are used'
    IMPACT = DetectorClassification.INFORMATIONAL
    CONFIDENCE = DetectorClassification.EXACTLY

    WIKI = 'https://github.com/SmartContractTools/SmartFast/wiki/Detector-Documentation#different-pragma-directives-are-used'


    WIKI_TITLE = 'Different pragma directives are used'
    WIKI_DESCRIPTION = 'Detect whether different Solidity versions are used.'
    WIKI_RECOMMENDATION = 'Use one Solidity version.'

    def _detect(self):
        results = []
        pragma = self.smartfast.pragma_directives
        versions = [p.version for p in pragma if p.is_solidity_version]
        versions = sorted(list(set(versions)))

        if len(versions) > 1:
            info = [f"Different versions of Solidity is used in {self.filename}:\n"]
            info += [f"\t- Version used: {[str(v) for v in versions]}\n"]

            for p in pragma:
                info += ["\t- ", p, "\n"]
  
            res = self.generate_result(info)

            results.append(res)

        return results

    @staticmethod
    def _format(smartfast, result):
        format(smartfast, result)
