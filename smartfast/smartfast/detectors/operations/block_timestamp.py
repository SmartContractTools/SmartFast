"""
    Module detecting dangerous use of block.timestamp

"""
from typing import List, Tuple

from smartfast.analyses.data_dependency.data_dependency import is_dependent
from smartfast.core.cfg.node import Node
from smartfast.core.declarations import Function, Contract
from smartfast.core.declarations.solidity_variables import (SolidityVariableComposed, SolidityVariable)
from smartfast.detectors.abstract_detector import (AbstractDetector,
                                                 DetectorClassification)
from smartfast.smartir.operations import Binary, BinaryType


def _timestamp(func: Function) -> List[Node]:
    ret = set()
    for node in func.nodes:
        if node.contains_require_or_assert():
            for var in node.variables_read:
                # print(var)
                if is_dependent(var, SolidityVariableComposed('block.timestamp'), func.contract):
                    ret.add(node)
                if is_dependent(var, SolidityVariable('now'), func.contract):
                    ret.add(node)
        for ir in node.irs:
            if isinstance(ir, Binary) and BinaryType.return_bool(ir.type):
                # print(ir.used[0])
                # print("----")
                # print(ir.read)
                for var in ir.read:
                    if is_dependent(var, SolidityVariableComposed('block.timestamp'), func.contract):
                        ret.add(node)
                    if is_dependent(var, SolidityVariable('now'), func.contract):
                        ret.add(node)
    return sorted(list(ret), key=lambda x: x.node_id)


def _detect_dangerous_timestamp(contract: Contract) -> List[Tuple[Function, List[Node]]]:
    """
    Args:
        contract (Contract)
    Returns:
        list((Function), (list (Node)))
    """
    ret = []
    # print(contract.all_functions_called)
    # print(contract.functions)
    for f in [f for f in contract.functions + contract.modifiers if f.contract_declarer == contract]:#修改这里，扩展函数，让它能检测到
        # print(f.is_shadowed)
        nodes = _timestamp(f)
        if nodes:
            ret.append((f, nodes))
    return ret


class Timestamp(AbstractDetector):
    """
    """

    ARGUMENT = 'timestamp'
    HELP = 'Dangerous usage of `block.timestamp`'
    IMPACT = DetectorClassification.LOW
    CONFIDENCE = DetectorClassification.PROBABLY

    WIKI = 'https://github.com/SmartContractTools/SmartFast/wiki/Detector-Documentation#block-timestamp'

    WIKI_TITLE = 'Block timestamp'
    WIKI_DESCRIPTION = 'Dangerous usage of `block.timestamp`. `block.timestamp` can be manipulated by miners.'
    WIKI_EXPLOIT_SCENARIO = '''
```solidity
contract Timestamp{
    event Time(uint);

    modifier onlyOwner {
        require(block.timestamp == 0);
        _;  
    }

    function bad0() external{
        require(block.timestamp == 0);
    }
}
```
    Bob's contract relies on `block.timestamp` for its randomness. Eve is a miner and manipulates `block.timestamp` to exploit Bob's contract.'''
    WIKI_RECOMMENDATION = 'Avoid relying on `block.timestamp`.'

    def _detect(self):
        """
        """
        results = []

        for c in self.contracts:
            # print(type(c))
            dangerous_timestamp = _detect_dangerous_timestamp(c)
            for (func, nodes) in dangerous_timestamp:

                info = [func, " uses timestamp for comparisons\n"]

                info += ['\tDangerous comparisons:\n']
                for node in nodes:
                    info += ['\t- ', node, '\n']

                res = self.generate_result(info)

                results.append(res)

        return results
