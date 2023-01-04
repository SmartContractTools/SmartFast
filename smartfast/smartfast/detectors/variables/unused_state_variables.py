"""
Module detecting unused state variables
"""

from smartfast.detectors.abstract_detector import AbstractDetector, DetectorClassification
from smartfast.core.solidity_types import ArrayType
from smartfast.visitors.expression.export_values import ExportValues
from smartfast.core.variables.state_variable import StateVariable
from smartfast.formatters.variables.unused_state_variables import custom_format as format

class UnusedStateVars(AbstractDetector):
    """
    Unused state variables detector
    """

    ARGUMENT = 'unused-state'
    HELP = 'Unused state variables'
    IMPACT = DetectorClassification.OPTIMIZATION
    CONFIDENCE = DetectorClassification.EXACTLY

    WIKI = 'https://github.com/SmartContractTools/SmartFast/wiki/Detector-Documentation#unused-state-variables'


    WIKI_TITLE = 'Unused state variable'
    WIKI_DESCRIPTION = 'Unused state variable.'
    WIKI_EXPLOIT_SCENARIO = ''
    WIKI_RECOMMENDATION = 'Remove unused state variables.'

    def detect_unused(self, contract):
        if contract.is_signature_only():
            return None
        # Get all the variables read in all the functions and modifiers

        all_functions = (contract.all_functions_called_notshadowed + contract.modifiers)
        variables_used = [x.state_variables_read for x in all_functions]
        variables_used += [x.state_variables_written for x in all_functions if not x.is_constructor_variables]

        array_candidates = [x.variables for x in all_functions]
        array_candidates = [i for sl in array_candidates for i in sl] + contract.state_variables
        array_candidates = [x.type.length for x in array_candidates if isinstance(x.type, ArrayType) and x.type.length]
        array_candidates = [ExportValues(x).result() for x in array_candidates]
        array_candidates = [i for sl in array_candidates for i in sl]
        array_candidates = [v for v in array_candidates if isinstance(v, StateVariable)]

        # Flat list
        variables_used = [item for sublist in variables_used for item in sublist]
        variables_used = list(set(variables_used + array_candidates))

        # print([x.name for x in contract.variables])
        # print([x.visibility for x in contract.variables])
        # Return the variables unused that are not public
        # return [x for x in contract.variables if
        #         x not in variables_used and (x.visibility == 'internal' or (x.visibility == 'private' and x.is_declared_by(contract)))]
        return [x for x in contract.variables if
                x not in variables_used and x.visibility != 'public']

    def _detect(self):
        """ Detect unused state variables
        """
        results = []
        for c in self.smartfast.contracts_derived:
            unusedVars = self.detect_unused(c)
            if unusedVars:
                for var in unusedVars:
                    # info = [var, " is never used in ", c, "\n"]
                    info = [var, " is never used\n"]
                    json = self.generate_result(info)
                    results.append(json)

        return results

    @staticmethod
    def _format(smartfast, result):
        format(smartfast, result)