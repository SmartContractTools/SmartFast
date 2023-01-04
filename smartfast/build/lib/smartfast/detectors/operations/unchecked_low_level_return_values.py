"""
Module detecting unused return values from low level
"""
from smartfast.detectors.abstract_detector import AbstractDetector,DetectorClassification
from .unused_return_values import UnusedReturnValues
from smartfast.smartir.operations import LowLevelCall,SolidityCall,Binary,Assignment,Condition,Return,Send,Unpack,TypeConversion,Unary
from smartfast.core.declarations import Function, SolidityFunction
# from smartfast.smartir.variables import TupleVariableSSA

class UncheckedLowLevelCalls(AbstractDetector):
    """
    If the return value of a send is not checked, it might lead to losing ether
    """

    ARGUMENT = 'unchecked-lowlevel'
    HELP = 'Unchecked low-level calls'
    IMPACT = DetectorClassification.MEDIUM
    CONFIDENCE = DetectorClassification.PROBABLY

    WIKI = 'https://github.com/SmartContractTools/SmartFast/wiki/Detector-Documentation#unchecked-low-level-calls'

    WIKI_TITLE = 'Unchecked low-level calls'
    WIKI_DESCRIPTION = 'The return value of a low-level call is not checked.'
    WIKI_EXPLOIT_SCENARIO = '''
```solidity
contract MyConc{
    function my_func(address payable dst) public payable{
        dst.call.value(msg.value)("");
    }
}
```
The return value of the low-level call is not checked, so if the call fails, the Ether will be locked in the contract.
If the low level is used to prevent blocking operations, consider logging failed calls.
    '''

    WIKI_RECOMMENDATION = 'Ensure that the return value of a low-level call is checked or logged.'

    _txt_description = "low-level calls"

    def taint_lowlevelcalls(self, functions):
        results = dict()
        taints = dict()
        # jiance = []
        for func in functions:
            # print("******************")
            # print(func.name)
            for node in func.nodes:
                # print(node.irs_ssa)
                # print(node)
                for ir in node.irs_ssa:
                    # print(node)
                    # print(ir)
                    # print(type(ir))
                    # if hasattr(ir, "lvalue"):
                    #     print(ir.lvalue)
                    if isinstance(ir, LowLevelCall):
                        if node not in taints:
                            taints[node] = []
                        # if isinstance(ir.lvalue, TupleVariableSSA):
                        #     print("TupleVariableSSA---")
                        #     print(ir.lvalue)
                        #     print(type(ir.lvalue))
                        taints[node].append(ir.lvalue.name)
                    # elif isinstance(ir, Send):
                    #     if node not in taints:
                    #         taints[node] = []
                    #     taints[node].append(ir.lvalue.name)
                    # elif isinstance(ir, SolidityCall) and ir.function.full_name in ["suicide(address)", "selfdestruct(address)"]:
                    #     if node not in taints:
                    #         taints[node] = []
                    #     taints[node].append(ir.lvalue.name)
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
                    elif isinstance(ir, TypeConversion):
                        variable_read = ir.variable.name
                        for k,v in taints.items():
                            if variable_read in v:
                                taints[k].append(ir.lvalue.name)
                    # elif isinstance(ir, SolidityCall):
                    #     # print('SOLIDITY_CALL:')
                    #     # print(type(ir.function))
                    #     if isinstance(ir.function, SolidityFunction) and\
                    #         ir.function.full_name in ['require(bool)', 'assert(bool)']:
                    #             # print(ir.function.full_name)
                    #             for k in list(taints.keys()):
                    #                 if ir.read[0].name in taints[k]:
                    #                     taints.pop(k)
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
                        # print("----------")
                        # print(ir.values)
                        # print(type(ir.values))
                        # print("----------")
                        values_name = [v.name for v in ir.values]
                        values_name_set = set(values_name)
                        for k in list(taints.keys()):
                            if values_name_set.intersection(taints[k]):
                                taints.pop(k)
                    if hasattr(ir, "arguments"):
                        # print("------arguments---------")
                        arguments_name = [v.name for v in ir.arguments if hasattr(v, "name")]
                        # print(arguments_name)
                        arguments_name_set = set(arguments_name)
                        for k in list(taints.keys()):
                            if arguments_name_set.intersection(taints[k]):
                                taints.pop(k)
        # print("------------")
        for k in taints.keys():
            # print(k.function)
            # print(k)
            # print([v for v in taints[k]])
            if k.function not in results:
                results[k.function] = [] #第一次就先创建一个数组
            results[k.function].append(k) #加的是node，以函数为单位，因为下面输出需要

        return results

    def detect_unchecked_lowlevelcalls(self, contract):
        # print(contract.modifiers)
        # print("---")
        # print(contract.all_functions_called)
        # print(contract.name)
        funcs = contract.all_functions_called + contract.modifiers
        # print(funcs)
        # print("------")
        # print([f for f in contract.functions + contract.modifiers if f.contract_declarer == contract])
        # print("*******")
        # Taint all low level calls
        results = self.taint_lowlevelcalls(funcs)

        return results

    def _detect(self):
        results = []

        for c in self.smartfast.contracts_derived:
            ret = self.detect_unchecked_lowlevelcalls(c)

            # sort ret to get deterministic results
            ret = sorted(list(ret.items()), key=lambda x:x[0].name)
            # print("sorted")
            # print(ret)
            for f, nodes in ret:

                func_info = [f, " unchecks return value:\n"]

                # sort the nodes to get deterministic results
                nodes.sort(key=lambda x: x.node_id)

                # Output each node with the function info header as a separate result.
                for node in nodes:
                    node_info = func_info + [f"\t- ", node, "\n"]

                    res = self.generate_result(node_info)
                    results.append(res)

        return results

    def _is_instance(self, ir):
        return isinstance(ir, LowLevelCall)