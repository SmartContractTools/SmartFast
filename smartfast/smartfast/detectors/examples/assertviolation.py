from smartfast.detectors.abstract_detector import AbstractDetector, DetectorClassification
from smartfast.core.cfg.node import NodeType
from smartfast.smartir.operations import (Assignment,Unpack,Binary,TypeConversion)
from smartfast.smartir.variables import Constant


class AssertViolation(AbstractDetector):
    """
    Detect function named backdoor
    """

    ARGUMENT = 'assert-violation'  # smartfast will launch the detector with smartfast.py --mydetector
    HELP = 'Wrong use of assert'
    IMPACT = DetectorClassification.MEDIUM
    CONFIDENCE = DetectorClassification.EXACTLY


    WIKI = 'https://github.com/trailofbits/smartfast/wiki/Assert-violation'
    WIKI_TITLE = 'AssertViolation'
    WIKI_DESCRIPTION = 'Wrong use of assert: Input variables should not be checked without verification measures.'
    WIKI_EXPLOIT_SCENARIO = '''
```solidity
contract Assertviolation [
    function bad(uint a, uint b){
        assert(a>b);
    }
}
```'''
    WIKI_RECOMMENDATION = 'To detect input variables, use the require function.'

    def findassert_violation(self, contract):
        results = []

        # print(contract.name)
        statevariable = contract.state_variables
        
        for f in contract.functions_and_modifiers_declared:
            if not f.is_implemented or f.is_protected():
                continue
            # print(f.name)
            ret = []
            checkvariable = statevariable + f.parameters
            relatevariable = []

            for node in f.nodes:
                # print(node)
                # print(node.type)
                if 'assert(bool)' in [v.name for v in node.solidity_calls]:
                    assertvalue = set([v for v in node.variables_read])
                    # print([v.name for v in assertvalue])
                    # print([v.name for v in checkvariable])
                    # print([v.name for v in relatevariable])
                    if assertvalue.intersection(checkvariable) and not assertvalue.intersection(relatevariable):
                        ret.append(node)
                for ir in node.irs:
                    if isinstance(ir, Assignment):
                        if ir._lvalue in relatevariable:
                            relatevariable.remove(ir._lvalue)
                        if ir._lvalue in checkvariable:
                            checkvariable.remove(ir._lvalue)
                        if ir.rvalue in checkvariable:
                            checkvariable.append(ir._lvalue)
                        if ir.rvalue in relatevariable:
                            relatevariable.append(ir._lvalue)
                    elif isinstance(ir, Unpack):
                        if ir._lvalue in relatevariable:
                            relatevariable.remove(ir._lvalue)
                        if ir._lvalue in checkvariable:
                            checkvariable.remove(ir._lvalue)
                    elif isinstance(ir, Binary):
                        # if not BinaryType.return_bool(ir.type):
                        # if (ir.variable_right in relatevariable or ir.variable_right in checkvariable) and (ir.variable_left not in relatevariable and ir.variable_left not in checkvariable):
                        #     relatevariable.append(ir.variable_left)
                        # if (ir.variable_left in relatevariable or ir.variable_left in checkvariable) and (ir.variable_right not in relatevariable and ir.variable_right not in checkvariable):
                        #     relatevariable.append(ir.variable_right)
                        if set([v for v in ir.read if not isinstance(v, Constant)]).intersection(relatevariable + checkvariable):
                            relatevariable.append(ir.lvalue)
                    elif isinstance(ir, TypeConversion):
                        if ir.variable in relatevariable:
                            relatevariable.append(ir.lvalue)
                        if ir.variable in checkvariable:
                            checkvariable.append(ir.lvalue)
                    # print(ir)
                
            if ret:
                results.append((f,ret))   
                # for ir in node.irs:
                #     print(ir)
                #     print(type(ir))
        return results

    def _detect(self):
        # print("***************")
        results = []

        for contract in self.smartfast.contracts:
            if any(v.name == 'assert' for v in contract.functions):
                continue

            assert_violation = self.findassert_violation(contract)
            for (func, nodes) in assert_violation:

                info = [func, " has assert violation\n"]
                info += ['\tAssert violations:\n']
                for node in nodes:
                    info += ['\t- ', node, '\n']

                res = self.generate_result(info)

                results.append(res)
        # print("***************")
        return results