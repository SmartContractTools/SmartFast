"""
Module detecting shadowing of state variables
"""

from smartfast.detectors.abstract_detector import AbstractDetector, DetectorClassification
from smartfast.core.declarations.function import Function, FunctionType


class FunctionShadowing(AbstractDetector):
    """
    Shadowing of function
    """

    ARGUMENT = 'shadowing-function'
    HELP = 'Function shadowing'
    IMPACT = DetectorClassification.LOW
    CONFIDENCE = DetectorClassification.EXACTLY

    WIKI = 'https://github.com/crytic/smartfast/wiki/Detector-Documentation#function-shadowing'

    WIKI_TITLE = 'Function shadowing'
    WIKI_DESCRIPTION = 'Detection of functions shadowed.'
    WIKI_EXPLOIT_SCENARIO = '''
```solidity
contract BaseContract{
    function aa(uint a,uint b) returns (uint) {
    return a;
    }
}

contract DerivedContract is BaseContract{
    function aa(uint a,uint b) returns (uint) {
    return b;
    }
}
```
`aa` of `BaseContract` does not work.'''

    WIKI_RECOMMENDATION = 'Change the names of hidden or hidden functions.'


    def detect_shadowing(self, contract):
        ret = []
        functions_fathers = []
        for father in contract.inheritance:
            if any(f.is_implemented for f in father.functions + father.modifiers):
                # print(father.name)
                # print([v.name for v in father.state_variables_declared])
                functions_fathers += [v for v in father.functions_and_modifiers_declared if v.function_type not in [FunctionType.CONSTRUCTOR_VARIABLES, FunctionType.CONSTRUCTOR_CONSTANT_VARIABLES, FunctionType.FALLBACK, FunctionType.CONSTRUCTOR]]

        # print([v.name for v in variables_fathers_used])
        for func in contract.functions_and_modifiers_declared:
            shadow = [v for v in functions_fathers if v.signature == func.signature]
            if shadow:
                ret.append([func] + shadow)
        return ret

    def _detect(self):
        """ Detect shadowing

        Recursively visit the calls
        Returns:
            list: {'vuln', 'filename,'contract','func', 'shadow'}

        """
        results = []
        for c in self.contracts:
            # print(c.name)
            # print("----------")
            shadowing = self.detect_shadowing(c)
            if shadowing:
                for all_functions in shadowing:
                    shadow = all_functions[0]
                    functions = all_functions[1:]
                    info = [shadow, ' shadows:\n']
                    for func in functions:
                        info += ["\t- ", func, "\n"]

                    res = self.generate_result(info)
                    results.append(res)


        return results
