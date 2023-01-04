"""
Module detecting numbers with too many digits.
"""

from smartfast.detectors.abstract_detector import AbstractDetector, DetectorClassification
from smartfast.smartir.variables import Constant
from smartfast.core.solidity_types.elementary_type import Byte


class TooManyDigits(AbstractDetector):
    """
    Detect numbers with too many digits
    """

    ARGUMENT = 'too-many-digits'
    HELP = 'Conformance to numeric notation best practices'
    IMPACT = DetectorClassification.INFORMATIONAL
    CONFIDENCE = DetectorClassification.PROBABLY

    WIKI = 'https://github.com/SmartContractTools/SmartFast/wiki/Detector-Documentation#too-many-digits'
    WIKI_TITLE = 'Too many digits'
    WIKI_DESCRIPTION = '''
Literals with many digits are difficult to read and review.
'''
    WIKI_EXPLOIT_SCENARIO = '''
```solidity
contract MyContract{
    uint 1_ether = 10000000000000000000; 
}
```

While `1_ether` looks like `1 ether`, it is `10 ether`. As a result, it's likely to be used incorrectly.
'''
    WIKI_RECOMMENDATION = '''
Use:
- [Ether suffix](https://solidity.readthedocs.io/en/latest/units-and-global-variables.html#ether-units),
- [Time suffix](https://solidity.readthedocs.io/en/latest/units-and-global-variables.html#time-units), or
- [The scientific notation](https://solidity.readthedocs.io/en/latest/types.html#rational-and-integer-literals)
'''

    @staticmethod
    def _detect_too_many_digits(f):
        # print("-----------")
        # print(f.name)
        ret = []
        for node in f.nodes:
            # print(node)
            # each node contains a list of IR instruction
            for ir in node.irs:
                # print(ir)
                # print(type(ir))
                # print([v for v in ir.read])
                # iterate over all the variables read by the IR
                for read in ir.read:
                    # if the variable is a constant
                    if isinstance(read, Constant):
                        read_type = str(read.type)
                        if read_type == 'string' or read_type in Byte:
                            continue
                        # print(read.type)
                        # read.value can return an int or a str. Convert it to str
                        value_as_str = read.original_value
                        # print(value_as_str)
                        # print(read._subdenomination)
                        if '00000' in value_as_str:
                            # Info to be printed
                            ret.append(node)
        return ret

    def _detect(self):
        results = []

        # iterate over all contracts
        for contract in self.smartfast.contracts_derived:
            # print(contract.name)
            # iterate over all functions
            for f in contract.functions + contract.modifiers:
                # iterate over all the nodes
                ret = self._detect_too_many_digits(f)
                if ret:
                    func_info = [f, ' uses literals with too many digits:']
                    for node in ret:
                        node_info = func_info + ['\n\t- ', node, '\n']

                        # Add the result in result
                        res = self.generate_result(node_info)
                        results.append(res)

        return results
