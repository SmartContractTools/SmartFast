from smartfast.detectors.abstract_detector import AbstractDetector, DetectorClassification
from smartfast.core.cfg.node import NodeType
from smartfast.smartir.operations import (Assignment,Unpack,Binary)


class ContinueinLoop(AbstractDetector):
    """
    Detect function named backdoor
    """

    ARGUMENT = 'continue-in-loop'  # smartfast will launch the detector with smartfast.py --mydetector
    HELP = 'Check continue in loop'
    IMPACT = DetectorClassification.HIGH
    CONFIDENCE = DetectorClassification.PROBABLY


    WIKI = 'https://github.com/trailofbits/smartfast/wiki/ContinueinLoop'
    WIKI_TITLE = 'ContinueinLoop'
    WIKI_DESCRIPTION = 'continue causes the judgment condition to fail, resulting in an infinite loop.'
    WIKI_EXPLOIT_SCENARIO = '''
```solidity
contract C {
    function f(uint a, uint b) public{
    uint a = 0;
    do {    
            continue;
            a++;
    } while(a<10);
    }
}
```'''
    WIKI_RECOMMENDATION = 'Check whether the increment variable is skipped.'

    def findcontinue_in_loop(self, contract):
        results = []

        # print(contract.name)
        for f in contract.functions_and_modifiers_declared:
            ret = []
            # print(f.name)
            # print("-------------")
            loops = []
            loops_if = []
            loops_condition = {}
            # node_val = None
            # inloop = False
            for node in f.nodes:
                # print(node)
                # print(node.type)
                if node.type == NodeType.STARTLOOP:
                    loops.append(node)
                    loops_if.append(True)
                    loops_condition[node] = []
                if node.type == NodeType.IFLOOP and loops:
                    # print([v.name for v in node.variables_read])
                    loops_condition[loops[-1]] = node.variables_read
                    for ir in node.irs:
                        # print(ir)
                        if isinstance(ir, Assignment):
                            loops_if[-1] = False
                            break
                        # print([v.name for v in ir.read])
                if node.type == NodeType.BREAK and loops:
                    loops_if[-1] = False
                if node.type == NodeType.RETURN and loops:
                    loops_if[-1] = False
                if node.type == NodeType.CONTINUE:
                    if loops and loops_if[-1]:
                        ret.append(loops[-1])
                        loops_if[-1] = False
                if node.type == NodeType.ENDLOOP and loops:
                    loops_condition.pop(loops[-1])
                    loops.pop()
                    loops_if.pop()
                for ir in node.irs:
                    # print(ir)
                    # print(type(ir))
                    if loops:
                        if isinstance(ir, Assignment):
                            if ir._lvalue in loops_condition[loops[-1]]:
                                # print(ir._lvalue.name)
                                # print([v.name for v in loops_condition[loops[-1]]])
                                loops_if[-1] = False
                                break
                        elif isinstance(ir, Unpack):
                            if ir._lvalue in loops_condition[loops[-1]]:
                                loops_if[-1] = False
                                break
                        elif isinstance(ir, Binary):
                            if ir.lvalue in loops_condition[loops[-1]]:
                                loops_if[-1] = False
                                break
            if ret:
                results.append((f,ret))   
                # for ir in node.irs:
                #     print(ir)
                #     print(type(ir))
        return results

    def _detect(self):
        results = []

        for contract in self.smartfast.contracts:
            continue_in_loop = self.findcontinue_in_loop(contract)
            for (func, nodes) in continue_in_loop:

                info = [func, " has the continue in the loop\n"]
                info += ['\tDangerous loops:\n']
                for node in nodes:
                    info += ['\t- ', node, '\n']

                res = self.generate_result(info)

                results.append(res)

        return results