"""
Module detecting unused return values from external calls
"""

from smartfast.detectors.abstract_detector import AbstractDetector, DetectorClassification
from smartfast.smartir.operations import HighLevelCall, InternalCall, InternalDynamicCall,LibraryCall,SolidityCall,Binary,TypeConversion
from smartfast.core.variables.state_variable import StateVariable
from smartfast.core.declarations import Function, SolidityFunction


class UnusedReturnValues(AbstractDetector):
    """
    If the return value of a function is never used, it's likely to be bug
    """

    ARGUMENT = 'unused-return'
    HELP = 'Unused return values'
    IMPACT = DetectorClassification.MEDIUM
    CONFIDENCE = DetectorClassification.PROBABLY

    WIKI = 'https://github.com/SmartContractTools/SmartFast/wiki/Detector-Documentation#unused-return'

    WIKI_TITLE = 'Unused return'
    WIKI_DESCRIPTION = 'The return value of an call is not stored in a local or state variable.'
    WIKI_EXPLOIT_SCENARIO = '''
```solidity
contract MyConc{
    using SafeMath for uint;   
    function my_func(uint a, uint b) public{
        a.add(b);
    }
}
```
`MyConc` calls `add` of `SafeMath`, but does not store the result in `a`. As a result, the computation has no effect.'''

    WIKI_RECOMMENDATION = 'Ensure that all the return values of the function calls are used.'

    _txt_description = "unused calls return value"

    def _is_instance(self, ir):
        return isinstance(ir, (HighLevelCall,InternalCall,SolidityCall,Binary,TypeConversion))

    def detect_unused_return_values(self, f):
        """
            Return the nodes where the return value of a call is unused
        Args:
            f (Function)
        Returns:
            list(Node)
        """
        values_returned = []
        nodes_origin = {}
        for n in f.nodes:
            # print(n)
            for ir in n.irs:
                # print(ir)
                # print(type(ir))
                if self._is_instance(ir):
                    # if a return value is stored in a state variable, it's ok
                    # print(type(ir))
                    # print(type(ir.lvalue))
                    # if ir.lvalue:
                        # print("haslvalue")
                        # print(ir.lvalue)
                        # print(type(ir.lvalue))
                        # print(ir.lvalue.type)
                    # print(hasattr(ir,"lvalue"))
                    # print(type(ir.lvalue))
                    # if ir.lvalue:
                    #     print("123")
                    # print("*********")
                    # print(ir)
                    if ir.lvalue:
                        # if ir.lvalue.type == None:
                        #     print("------------")
                            # print(ir.lvalue)
                            # continue;
                            # print(ir.function.full_name)
                        if ir.lvalue.type != None and not isinstance(ir.lvalue, StateVariable):
                        # print(ir.lvalue.name)
                            values_returned.append(ir.lvalue)
                            nodes_origin[ir.lvalue] = ir
                for read in ir.read:
                    # print(read)
                    if read in values_returned:
                        values_returned.remove(read)

        return [nodes_origin[value].node for value in values_returned]

    def _detect(self):
        """ Detect high level calls which return a value that are never used
        """
        results = []
        for c in self.smartfast.contracts:
            for f in c.functions + c.modifiers:
                if f.contract_declarer != c:
                    continue
                unused_return = self.detect_unused_return_values(f)
                if unused_return:

                    for node in unused_return:
                        info = [f, f" ignores return value by ", node, "\n"]

                        res = self.generate_result(info)

                        results.append(res)

        return results

