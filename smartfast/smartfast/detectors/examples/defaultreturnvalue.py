from smartfast.detectors.abstract_detector import AbstractDetector, DetectorClassification
from smartfast.core.cfg.node import NodeType
from smartfast.smartir.operations import (Assignment,Unpack,Binary)


class DefaultReturnValue(AbstractDetector):
    """
    Detect function named backdoor
    """

    ARGUMENT = 'default-return-value'  # smartfast will launch the detector with smartfast.py --mydetector
    HELP = 'The function only returns the default value'
    IMPACT = DetectorClassification.MEDIUM
    CONFIDENCE = DetectorClassification.EXACTLY


    WIKI = 'https://github.com/trailofbits/smartfast/wiki/default-return-value'
    WIKI_TITLE = 'DefaultReturnValue'
    WIKI_DESCRIPTION = 'The function only returns the default value.'
    WIKI_EXPLOIT_SCENARIO = '''
```solidity
contract C{
    function bad_return() public returns(bool flag){
    address aa = msg.sender;
    }

    function bad_return1() public returns(bool){
    address aa = msg.sender;
    }
}
```'''
    WIKI_RECOMMENDATION = 'The function with a return value should return, or change the return value.'

    def finddefault_returnvalue(self, contract):
        results = []

        # print(contract.name)
        for f in contract.functions_declared:
            if f.is_implemented:
                # print(f.name)
                # print("return initialized:")
                returnvalue = set(f.returns)
                writtenvalue = f.variables_written
                # print([v.name for v in f.returns])
                # print([v.name for v in f.variables_written])
                if not returnvalue.issubset(writtenvalue):
                    ifreturn = False
                    for node in f.nodes:
                        if node.type == NodeType.RETURN:
                            ifreturn = True
                            break
                    if not ifreturn:
                        results.append(f)
        return results

    def _detect(self):
        results = []
        # print("------------")
        for contract in self.smartfast.contracts:
            default_returnvalue = self.finddefault_returnvalue(contract)
        # print("---------------")
            if default_returnvalue:
                info = [contract, " has the function that can only return the default value\n"]
                info += ['\tDefault value functions:\n']
                for func in default_returnvalue:        
                    info += ['\t- ', func, '\n']

                res = self.generate_result(info)

                results.append(res)
        return results