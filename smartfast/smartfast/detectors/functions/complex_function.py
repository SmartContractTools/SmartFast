from smartfast.core.declarations.solidity_variables import (SolidityFunction,
                                                          SolidityVariableComposed)
from smartfast.detectors.abstract_detector import (AbstractDetector,
                                                 DetectorClassification)
from smartfast.smartir.operations import (HighLevelCall,
                                        LowLevelCall,
                                        LibraryCall)
from smartfast.utils.code_complexity import compute_cyclomatic_complexity


class ComplexFunction(AbstractDetector):
    """
    Module detecting complex functions
        A complex function is defined by:
            - high cyclomatic complexity
            - numerous writes to state variables
            - numerous external calls
    """
    WIKI = 'https://github.com/SmartContractTools/SmartFast/wiki/Detector-ComplexFunction#complex'

    ARGUMENT = 'complex-function'
    HELP = 'Complex functions'
    IMPACT = DetectorClassification.INFORMATIONAL
    CONFIDENCE = DetectorClassification.PROBABLY

    MAX_STATE_VARIABLES = 10
    MAX_EXTERNAL_CALLS = 5
    MAX_CYCLOMATIC_COMPLEXITY = 7

    CAUSE_CYCLOMATIC = "cyclomatic"
    CAUSE_EXTERNAL_CALL = "external_calls"
    CAUSE_STATE_VARS = "state_vars"

    WIKI_TITLE = 'complexfunction'
    WIKI_DESCRIPTION = 'The contract is too complicated and may cause gas overflow.'
    WIKI_EXPLOIT_SCENARIO = '''
```solidity
contract Complex {
    function a() {
        int numberOfSides = 7;
        string shape;
        uint i0 = 0;
        uint i1 = 0;
        uint i2 = 0;
        uint i3 = 0;
        uint i4 = 0;
        uint i5 = 0;
        uint i6 = 0;
        uint i7 = 0;
        uint i8 = 0;
        uint i9 = 0;
        uint i10 = 0;
        ...
    }
}
```
Bob calling function a() will exceed the gas limit, and the call will never succeed.'''

    WIKI_RECOMMENDATION = 'The function can be optimized if possible.'
    STANDARD_JSON = True

    @staticmethod
    def detect_complex_func(func):
        """Detect the cyclomatic complexity of the contract functions
           shouldn't be greater than 7
        """
        result = []
        code_complexity = compute_cyclomatic_complexity(func)

        if code_complexity > ComplexFunction.MAX_CYCLOMATIC_COMPLEXITY:
            result.append({
                "func": func,
                "cause": ComplexFunction.CAUSE_CYCLOMATIC
            })

        """Detect the number of external calls in the func
           shouldn't be greater than 5
        """
        count = 0
        for node in func.nodes:
            for ir in node.irs:
                if isinstance(ir, (HighLevelCall, LowLevelCall, LibraryCall)):
                    count += 1

        if count > ComplexFunction.MAX_EXTERNAL_CALLS:
            result.append({
                "func": func,
                "cause": ComplexFunction.CAUSE_EXTERNAL_CALL
            })

        """Checks the number of the state variables written
           shouldn't be greater than 10
        """
        if len(func.state_variables_written) > ComplexFunction.MAX_STATE_VARIABLES:
            result.append({
                "func": func,
                "cause": ComplexFunction.CAUSE_STATE_VARS
            })

        return result

    def detect_complex(self, contract):
        ret = []

        for func in contract.all_functions_called:
            result = self.detect_complex_func(func)
            ret.extend(result)

        return ret

    def _detect(self):
        results = []

        for contract in self.contracts:
            issues = self.detect_complex(contract)

            for issue in issues:
                func, cause = issue.values()

                txt = "{} ({}) is a complex function:\n"

                if cause == self.CAUSE_EXTERNAL_CALL:
                    txt += "\t- Reason: High number of external calls"
                if cause == self.CAUSE_CYCLOMATIC:
                    txt += "\t- Reason: High number of branches"
                if cause == self.CAUSE_STATE_VARS:
                    txt += "\t- Reason: High number of modified state variables"

                info = txt.format(func.canonical_name,
                                  func.source_mapping_str)
                info = info + "\n"
                # self.log(info)

                res = self.generate_result(info)
                res.add(func, {
                    'high_number_of_external_calls': cause == self.CAUSE_EXTERNAL_CALL,
                    'high_number_of_branches': cause == self.CAUSE_CYCLOMATIC,
                    'high_number_of_state_variables': cause == self.CAUSE_STATE_VARS
                })

                results.append(res)

        return results
