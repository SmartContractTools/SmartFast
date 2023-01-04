"""
"""
from smartfast.core.cfg.node import NodeType
from smartfast.detectors.abstract_detector import (AbstractDetector,
                                                 DetectorClassification)
from smartfast.smartir.operations import (HighLevelCall, LibraryCall,
                                        LowLevelCall, Send, Transfer)


class MultipleCallsInLoop(AbstractDetector):
    """
    """

    ARGUMENT = 'calls-loop'
    HELP = 'Multiple calls in a loop'
    IMPACT = DetectorClassification.LOW
    CONFIDENCE = DetectorClassification.PROBABLY

    WIKI = 'https://github.com/SmartContractTools/SmartFast/wiki/Detector-Documentation/#calls-inside-a-loop'


    WIKI_TITLE = 'Calls inside a loop'
    WIKI_DESCRIPTION = 'Calls inside a loop might lead to a denial-of-service attack.'
    WIKI_EXPLOIT_SCENARIO = '''
```solidity
contract CallsInLoop{

    address[] destinations;

    constructor(address[] newDestinations) public{
        destinations = newDestinations;
    }

    function bad() external{
        for (uint i=0; i < destinations.length; i++){
            destinations[i].transfer(i);
        }
    }

}
```
If one of the destinations has a fallback function that reverts, `bad` will always revert.'''

    WIKI_RECOMMENDATION = 'Favor [pull over push](https://github.com/ethereum/wiki/wiki/Safety#favor-pull-over-push-for-external-calls) strategy for external calls.'

    @staticmethod
    def call_in_loop(node, in_loop, visited, ret):
        # print(node)
        # print(node.type)
        if node in visited:
            return
        # shared visited
        visited.append(node)

        if node.type == NodeType.STARTLOOP:
            in_loop = True
        elif node.type == NodeType.ENDLOOP:
            in_loop = False

        if in_loop:
            for ir in node.irs:
                # print(ir)
                # print(type(ir))
                if isinstance(ir, (LowLevelCall,
                                   HighLevelCall,
                                   Send,
                                   Transfer)):
                    if isinstance(ir, LibraryCall):
                        continue
                    ret.append(node)

        for son in node.sons:
            MultipleCallsInLoop.call_in_loop(son, in_loop, visited, ret)

    @staticmethod
    def detect_call_in_loop(contract):
        ret = []
        # print(contract.name)
        # print("**********")
        for f in contract.functions_and_modifiers_declared:#2改函数
            # print(f.name)
            # print(f.contract_declarer)
            if f.is_implemented:#3改限制
                # print(f.name)
                # print("---")
                MultipleCallsInLoop.call_in_loop(f.entry_point,
                                                 False, [], ret)
            # print("-----------")

        return ret

    def _detect(self):
        """
        """
        results = []
        for c in self.contracts: #改合约
            values = self.detect_call_in_loop(c)
            for node in values:
                func = node.function

                info = [func, " has external calls inside a loop: ", node, "\n"]
                res = self.generate_result(info)
                results.append(res)

        return results
