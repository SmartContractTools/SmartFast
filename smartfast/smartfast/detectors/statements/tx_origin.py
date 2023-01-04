"""
Module detecting usage of `tx.origin` in a conditional node
"""

from smartfast.detectors.abstract_detector import AbstractDetector, DetectorClassification
from smartfast.smartir.operations import Assignment, Call, Return, InitArray, Binary, BinaryType, SolidityCall, Condition
from smartfast.core.declarations import Function, SolidityFunction

class TxOrigin(AbstractDetector):
    """
    Detect usage of tx.origin in a conditional node
    """

    ARGUMENT = 'tx-origin'
    HELP = 'Dangerous usage of `tx.origin`'
    IMPACT = DetectorClassification.MEDIUM
    CONFIDENCE = DetectorClassification.PROBABLY

    WIKI = 'https://github.com/SmartContractTools/SmartFast/wiki/Detector-Documentation#dangerous-usage-of-txorigin'

    WIKI_TITLE = 'Dangerous usage of `tx.origin`'
    WIKI_DESCRIPTION = '`tx.origin`-based protection can be abused by a malicious contract if a legitimate user interacts with the malicious contract.'
    WIKI_EXPLOIT_SCENARIO = '''
```solidity
contract TxOrigin {
    address owner = msg.sender;

    function bug() {
        require(tx.origin == owner);
    }
}
```
Bob is the owner of `TxOrigin`. Bob calls Eve's contract. Eve's contract calls `TxOrigin` and bypasses the `tx.origin` protection.'''

    WIKI_RECOMMENDATION = 'Do not use `tx.origin` for authorization.'

    @staticmethod
    def detect_tx_origin_taints(functions):#Pollution balance_equalities
        taints = []
        ret_val = dict()
        for func in functions:
            # print(func.name)
            for node in func.nodes:
                for ir in node.irs_ssa:
                    # print(ir)
                    # print(type(ir))
                    if isinstance(ir, Assignment):
                        assig_rvalue = ir.rvalue.name
                        assig_lvalue = ir._lvalue.name
                        # print(assig_rvalue)
                        # print(assig_lvalue)
                        if assig_rvalue in taints:
                            taints.append(assig_lvalue)
                        elif assig_rvalue == 'tx.origin':
                            taints.append(assig_lvalue)
                    elif isinstance(ir, Binary):
                        # print(ir.type)
                        lrval_name = [v.name for v in ir.read]
                        if 'tx.origin' in lrval_name and 'msg.sender' not in  lrval_name and ir.lvalue.name not in taints:
                            taints.append(ir.lvalue.name)
                        elif (ir.type != BinaryType.ANDAND) and list(set(lrval_name)&set(taints)) and ir.lvalue.name not in taints:
                            taints.append(ir.lvalue.name)
                        # for val in lrval:
                        #     print(val)
                        #     print(val.name)
                        # print(ir.lvalue)
                    elif isinstance(ir, SolidityCall):
                        # print('SOLIDITY_CALL:')
                        # print(type(ir.function))
                        if isinstance(ir.function, SolidityFunction) and\
                            ir.function.full_name in ['require(bool)', 'assert(bool)'] and\
                            ir.read[0].name in taints:
                                # print("SolidityFunction:------------------node")
                                # print(ir.read[0].name)
                                if func not in ret_val:
                                    ret_val[func] = [] #contruct a list for a function
                                ret_val[func].append(node) #add node for the function
                                taints.append(ir.lvalue)
                        # print(ir.function.full_name)
                        # print(len(ir.read))
                    elif isinstance(ir, Condition) and ir.value.name in taints:
                        # print('CONDITION:')
                        # print("CONDITION:------------------node")
                        # print(node)
                        if func not in ret_val:
                            ret_val[func] = [] #contruct a list for a function
                        ret_val[func].append(node) #add node for the function
                # print("------")
        # print("------")
        # for ta in taints:
        #     print(ta)
        # print("------")
        # for ta in ret_val:
        #     print(ta)
        return ret_val
    
    def detect_tx_origin(self, contract):
        funcs = contract.all_functions_called + contract.modifiers

        ret = self.detect_tx_origin_taints(funcs)
        
        return ret

    def _detect(self):
        """ Detect the functions that use tx.origin in a conditional node
        """
        results = []
        for c in self.smartfast.contracts_derived:
            values = self.detect_tx_origin(c)
            #sort ret to get deterministic results
            values = sorted(list(values.items()), key=lambda x:x[0].name)
            for func, nodes in values:
                # sort the nodes to get deterministic results
                nodes.sort(key=lambda x: x.node_id)
                for node in nodes:
                    info = [func, " uses tx.origin for authorization: ", node, "\n"]
                    res = self.generate_result(info)
                    results.append(res)

        return results