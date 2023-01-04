from smartfast.detectors.abstract_detector import AbstractDetector, DetectorClassification
from smartfast.core.cfg.node import NodeType
from smartfast.smartir.operations import (Assignment,Unpack,Binary,EventCall)


class Eventbeforerevert(AbstractDetector):
    """
    Detect function named backdoor
    """

    ARGUMENT = 'event-before-revert'  # smartfast will launch the detector with smartfast.py --mydetector
    HELP = 'Revert rollback will make the event waste gas'
    IMPACT = DetectorClassification.OPTIMIZATION
    CONFIDENCE = DetectorClassification.EXACTLY


    WIKI = 'https://github.com/trailofbits/smartfast/wiki/Eventbeforerevert'
    WIKI_TITLE = 'Eventbeforerevert'
    WIKI_DESCRIPTION = 'Revert rollback will make the event waste gas.'
    WIKI_EXPLOIT_SCENARIO = '''
```solidity
contract Callbeforerevert {
    address owner;
    event EventName(address bidder, uint amount);
    function bad() public {
        emit EventName(msg.sender, msg.value); 
        revert();
    }
    function bad1() public {
        emit EventName(msg.sender, msg.value); 
        throw;
    }
    function bad2() public {
        if(msg.sender == owner) {
            emit EventName(msg.sender, msg.value); 
            throw;
        }
    }
    function bad3() public {
        if(msg.sender == owner) {
            emit EventName(msg.sender, msg.value); 
            revert();
        }
    }
}
```'''
    WIKI_RECOMMENDATION = 'Check the logical structure of the contract function.'

    @staticmethod
    def event_before_revert(node, iniforloop, visited, ret):
        # print(node)
        # print(node.type)
        if node in visited:
            return
        # shared visited
        visited.append(node)

        if node.type == NodeType.THROW or 'revert()' in [v.name for v in node.solidity_calls]:
            if iniforloop == 0:
                ret.append(node)
                return
        # print([v.name for v in node.solidity_calls])
        if node.type in [NodeType.IF, NodeType.STARTLOOP]:
            iniforloop = iniforloop + 1
        if node.type in [NodeType.ENDIF, NodeType.ENDLOOP]:
            if iniforloop ==0:
                return
            iniforloop = iniforloop - 1

        for son in node.sons:
            Eventbeforerevert.event_before_revert(son, iniforloop, visited, ret)

    def findevent_before_revert(self, contract):
        results = []
        # print(contract.name)
        for f in contract.functions_and_modifiers_declared:
            if not f.is_implemented:
                continue
            ret = []
            # print(f.name)
            for node in f.nodes:
                # print(node)
                # print(node.type)
                for ir in node.irs:
                    if isinstance(ir, EventCall):
                        iniforloop = 0
                        ret_val = []
                        Eventbeforerevert.event_before_revert(ir.node,iniforloop,[],ret_val)
                        if ret_val:
                            ret.append((ir.node,ret_val))
                    # print(ir)
                    # print(type(ir))       
            if ret:
                results.append((f,ret))

        return results

    def _detect(self):
        results = []
        # print("-------------------------------------")
        for contract in self.smartfast.contracts:
            event_revert = self.findevent_before_revert(contract)
            for (func,nodes) in event_revert:
                info = [func, " logic is abnormal, the event call is called before revert():\n"]
                for (node,revert_node) in nodes:
                    info += ['\t- ', node, ' was rolled back in the following situations:', '\n']
                    for revert_node_value in revert_node:
                        info += ['\t\t- ', revert_node_value, '\n']
                    # print(revert_node)                    
                res = self.generate_result(info)

                results.append(res)
        # print("-------------------------------------")
        return results