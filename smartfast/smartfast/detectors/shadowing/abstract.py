"""
Module detecting shadowing variables on abstract contract
Recursively check the called functions
"""

from smartfast.detectors.abstract_detector import AbstractDetector, DetectorClassification
from smartfast.core.declarations.function import Function, FunctionType


class ShadowingAbstractDetection(AbstractDetector):
    """
    Shadowing detection
    """

    ARGUMENT = 'shadowing-abstract'
    HELP = 'State variables shadowing from abstract contracts'
    IMPACT = DetectorClassification.MEDIUM
    CONFIDENCE = DetectorClassification.EXACTLY

    WIKI = 'https://github.com/SmartContractTools/SmartFast/wiki/Detector-Documentation#state-variable-shadowing-from-abstract-contracts'


    WIKI_TITLE = 'State variable shadowing from abstract contracts'
    WIKI_DESCRIPTION = 'Detection of state variables shadowed from abstract contracts.'
    WIKI_EXPLOIT_SCENARIO = '''
```solidity
contract BaseContract{
    address owner;
}

contract DerivedContract is BaseContract{
    address owner;
}
```
`owner` of `BaseContract` is shadowed in `DerivedContract`.'''

    WIKI_RECOMMENDATION = 'Remove the state variable shadowing.'


    def detect_shadowing(self, contract):
        ret = []
        variables_fathers = []
        variables_fathers_used = []
        for father in contract.inheritance:
            variables_used = [list(set(v.all_state_variables_read() + v.all_state_variables_written())) for v in father.functions_and_modifiers_declared if v.function_type not in [FunctionType.CONSTRUCTOR_VARIABLES, FunctionType.CONSTRUCTOR_CONSTANT_VARIABLES]]
            variables_used = list(set([v for sub in variables_used for v in sub]))
            variables_fathers_used += variables_used
            variables_fathers += father.state_variables_declared
            # print(father.name)

        # print([v.name for v in variables_fathers])
            # print([v.name for v in variables_fathers_used])

        variables_fathers_used = list(set(variables_fathers_used))
        for var in contract.state_variables_declared:
            shadow = [v for v in variables_fathers if v.name == var.name and v not in variables_fathers_used]
            if shadow:
                ret.append([var] + shadow)
        return ret


    def _detect(self):
        """ Detect shadowing

        Recursively visit the calls
        Returns:
            list: {'vuln', 'filename,'contract','func', 'shadow'}

        """
        results = []
        for c in self.contracts:
            shadowing = self.detect_shadowing(c)
            if shadowing:
                for all_variables in shadowing:
                    shadow = all_variables[0]
                    variables = all_variables[1:]
                    info = [shadow, ' shadows:\n']
                    for var in variables:
                        info += ["\t- ", var, "\n"]

                    res = self.generate_result(info)

                    results.append(res)

        return results
