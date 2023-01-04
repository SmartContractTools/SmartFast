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


def _otherparameter(func: Function) -> List[Node]:
    ret = set()
    for node in func.nodes:
        if node.contains_require_or_assert():
            for var in node.variables_read:
                # print(var)
                if is_dependent(var, SolidityVariableComposed('block.coinbase'), func.contract):
                    ret.add(node)
                if is_dependent(var, SolidityVariableComposed('block.difficulty'), func.contract):
                    ret.add(node)
                if is_dependent(var, SolidityVariableComposed('block.gaslimit'), func.contract):
                    ret.add(node)
                if is_dependent(var, SolidityVariableComposed('block.number'), func.contract):
                    ret.add(node)
        for ir in node.irs:
            if isinstance(ir, Binary) and BinaryType.return_bool(ir.type):
                # print(ir.used[0])
                # print("----")
                # print(ir.read)
                for var in ir.read:
                    if is_dependent(var, SolidityVariableComposed('block.coinbase'), func.contract):
                        ret.add(node)
                    if is_dependent(var, SolidityVariableComposed('block.difficulty'), func.contract):
                        ret.add(node)
                    if is_dependent(var, SolidityVariableComposed('block.gaslimit'), func.contract):
                        ret.add(node)
                    if is_dependent(var, SolidityVariableComposed('block.number'), func.contract):
                        ret.add(node) 
    return sorted(list(ret), key=lambda x: x.node_id)


def _detect_dangerous_otherparameter(contract: Contract) -> List[Tuple[Function, List[Node]]]:
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
        nodes = _otherparameter(f)
        if nodes:
            ret.append((f, nodes))
    return ret


class BlockOtherparameters(AbstractDetector):
    """
    """

    ARGUMENT = 'block-other-parameters'
    HELP = 'Dangerous usage of `block.number` etc.'
    IMPACT = DetectorClassification.LOW
    CONFIDENCE = DetectorClassification.PROBABLY

    WIKI = 'https://github.com/SmartContractTools/SmartFast/wiki/Detector-Documentation#block-other-parameters'

    WIKI_TITLE = 'Block timestamp'
    WIKI_DESCRIPTION = 'Dangerous usage of `block.number` etc. `block.number` etc. can be manipulated by miners.'
    WIKI_EXPLOIT_SCENARIO = '''
```solidity
contract Otherparameters{
    event Number(uint);
    event Coinbase(address);
    event Difficulty(uint);
    event Gaslimit(uint);

    function bad0() external{
        require(block.number == 20);
        require(block.coinbase == msg.sender);
        require(block.difficulty == 20);
        require(block.gaslimit == 20);
    }
}
```
    Bob's contract relies on `block.number` etc. for its randomness. Eve is a miner and manipulates `block.number` etc. to exploit Bob's contract.'''
    WIKI_RECOMMENDATION = 'Avoid relying on `block.number`etc.'

    def _detect(self):
        """
        """
        results = []

        for c in self.contracts:
            # print(type(c))
            dangerous_otherparameter = _detect_dangerous_otherparameter(c)
            for (func, nodes) in dangerous_otherparameter:

                info = [func, " uses the other parameters of block for comparisons\n"]

                info += ['\tDangerous comparisons:\n']
                for node in nodes:
                    info += ['\t- ', node, '\n']

                res = self.generate_result(info)

                results.append(res)

        return results
