"""
Module detecting unused return values from send
"""

from smartfast.detectors.abstract_detector import AbstractDetector,DetectorClassification
from .unused_return_values import UnusedReturnValues
from smartfast.smartir.operations import Send,Binary,Assignment,Condition,Return,Unpack,Unary
from smartfast.core.declarations import Function, SolidityFunction

class UncheckedSend(AbstractDetector):
    """
    If the return value of a send is not checked, it might lead to losing ether
    """

    ARGUMENT = 'unchecked-send'
    HELP = 'Unchecked send'
    IMPACT = DetectorClassification.MEDIUM
    CONFIDENCE = DetectorClassification.PROBABLY

    WIKI = 'https://github.com/SmartContractTools/SmartFast/wiki/Detector-Documentation#unchecked-send'

    WIKI_TITLE = 'Unchecked Send'
    WIKI_DESCRIPTION = 'The return value of a `send` is not checked.'
    WIKI_EXPLOIT_SCENARIO = '''
```solidity
contract MyConc{
    function my_func(address payable dst) public payable{
        dst.send(msg.value);
    }
}
```
The return value of `send` is not checked, so if the send fails, the Ether will be locked in the contract.
If `send` is used to prevent blocking operations, consider logging the failed `send`.
    '''

    WIKI_RECOMMENDATION = 'Ensure that the return value of `send` is checked or logged.'

    _txt_description = "send calls"

    def taint_sendcalls(self, functions):
        results = dict()
        taints = dict()
        # jiance = []
        for func in functions:
            # print("******************")
            # print(func.name)
            for node in func.nodes:
                # print(node.irs_ssa)
                for ir in node.irs_ssa:
                    if isinstance(ir, Send):
                        if node not in taints:
                            taints[node] = []
                        taints[node].append(ir.lvalue.name)
                    elif isinstance(ir, Binary):
                        # print(ir.type)
                        lrval_name = [v.name for v in ir.read]
                        for k,v in taints.items():
                            if set(lrval_name).intersection(v):
                                taints[k].append(ir.lvalue.name)
                    elif isinstance(ir, Unary):
                        for k,v in taints.items():
                            if ir.rvalue.name in v:
                                taints[k].append(ir.lvalue.name)
                    elif isinstance(ir, Assignment):
                        assig_rvalue = ir.rvalue.name
                        assig_lvalue = ir._lvalue.name
                        for k,v in taints.items():
                            if assig_rvalue in v:
                                taints[k].append(assig_lvalue)
                    elif isinstance(ir, Unpack):
                        unpack_name = [v.name for v in ir.read]
                        unpack_name_set = set(unpack_name)  
                        # print(ir.lvalue)
                        for k,v in taints.items():
                            if unpack_name_set.intersection(v):
                                taints[k].append(ir.lvalue.name)
                    elif isinstance(ir, Condition):
                        for k in list(taints.keys()):
                            if ir.value.name in taints[k]:
                                taints.pop(k)
                    elif isinstance(ir, Return):
                        values_name = [v.name for v in ir.values]
                        values_name_set = set(values_name)
                        for k in list(taints.keys()):
                            if values_name_set.intersection(taints[k]):
                                taints.pop(k)
                    if hasattr(ir, "arguments"):
                        # print("------arguments---------")
                        arguments_name = [v.name for v in ir.arguments if hasattr(v, "name")]
                        arguments_name_set = set(arguments_name)
                        for k in list(taints.keys()):
                            if arguments_name_set.intersection(taints[k]):
                                taints.pop(k)
        for k in taints.keys():
            # print(k.function)
            if k.function not in results:
                results[k.function] = [] #第一次就先创建一个数组
            results[k.function].append(k) #加的是node，以函数为单位，因为下面输出需要

        return results

    def detect_unchecked_sendcalls(self, contract):
        # print(contract.modifiers)
        funcs = contract.all_functions_called + contract.modifiers
        # print(funcs)
        # Taint all send calls
        results = self.taint_sendcalls(funcs)

        return results

    def _detect(self):
        results = []

        for c in self.smartfast.contracts_derived:
            ret = self.detect_unchecked_sendcalls(c)

            # sort ret to get deterministic results
            ret = sorted(list(ret.items()), key=lambda x:x[0].name)
            # print("sorted")
            # print(ret)
            for f, nodes in ret:

                func_info = [f, " unchecks send return value:\n"]

                # sort the nodes to get deterministic results
                nodes.sort(key=lambda x: x.node_id)

                # Output each node with the function info header as a separate result.
                for node in nodes:
                    node_info = func_info + [f"\t- ", node, "\n"]

                    res = self.generate_result(node_info)
                    results.append(res)

        return results


    def _is_instance(self, ir):
        return isinstance(ir, Send)