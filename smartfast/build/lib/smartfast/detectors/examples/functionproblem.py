from smartfast.detectors.abstract_detector import AbstractDetector, DetectorClassification
from smartfast.core.cfg.node import NodeType
from smartfast.smartir.operations import (Assignment,Unpack,Binary)


class Functionproblem(AbstractDetector):
    """
    Detect function named backdoor
    """

    ARGUMENT = 'function-problem'  # smartfast will launch the detector with smartfast.py --mydetector
    HELP = 'Contract function ended abnormally'
    IMPACT = DetectorClassification.MEDIUM
    CONFIDENCE = DetectorClassification.PROBABLY


    WIKI = 'https://github.com/trailofbits/smartfast/wiki/Functionproblem'
    WIKI_TITLE = 'Functionproblem'
    WIKI_DESCRIPTION = 'The function always ends with revert and throw states.'
    WIKI_EXPLOIT_SCENARIO = '''
```solidity
contract Functionproblem {
    address owner;
    function bad() { //bad
        revert();
    }
}
```'''
    WIKI_RECOMMENDATION = 'Check the logical structure of the contract function.'

    @staticmethod
    def function_problem(node, iniforloop, visited, ret):
        # print(node)
        # print(node.type)
        if node in visited:
            return
        # shared visited
        visited.append(node)

        if (hasattr(node,'type') and node.type == NodeType.THROW) or (hasattr(node,'solidity_calls') and 'revert()' in [v.name for v in node.solidity_calls]):
            if iniforloop == 0:
                ret.append(node)
                return
        # print([v.name for v in node.solidity_calls])
        if hasattr(node,'type') and node.type in [NodeType.IF, NodeType.STARTLOOP]:
            iniforloop = iniforloop + 1
        if hasattr(node,'type') and node.type in [NodeType.ENDIF, NodeType.ENDLOOP]:
            iniforloop = iniforloop - 1

        if hasattr(node,'sons'):
            for son in node.sons:
                Functionproblem.function_problem(son, iniforloop, visited, ret)

    def findfunctionproblem(self, contract):
        results = []
        # print(contract.name)
        for f in contract.functions_and_modifiers_declared:
            iniforloop = 0
            # print(f.name)
            ret = []
            Functionproblem.function_problem(f.entry_point,iniforloop,[],ret)
            if ret:
                results.append((f,ret))

        return results

    def _detect(self):
        results = []
        # print("-------------------------------------")
        for contract in self.smartfast.contracts:
            functionproblem = self.findfunctionproblem(contract)
            for (func,nodes) in functionproblem:

                info = [func, " logic is abnormal, abnormal termination statement:\n"]
                for node in nodes:
                    info += ['\t- ', node, '\n']

                res = self.generate_result(info)

                results.append(res)
        # print("-------------------------------------")
        return results