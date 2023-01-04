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
            # node_val = None
            # inloop = False
            for node in f.nodes:
                
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