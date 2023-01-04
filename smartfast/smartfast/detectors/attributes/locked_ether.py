"""
    Check if ethers are locked in the contract
"""

from smartfast.detectors.abstract_detector import (AbstractDetector,
                                                 DetectorClassification)
from smartfast.smartir.operations import (HighLevelCall, LowLevelCall, Send,
                                        Transfer, NewContract, LibraryCall, InternalCall,Assignment,Unpack)
from smartfast.smartir.variables import Constant
from smartfast.core.declarations.function import Function, FunctionType
# import copy

class LockedEther(AbstractDetector):
    """
    """

    ARGUMENT = 'locked-ether'
    HELP = "Contracts that lock ether"
    IMPACT = DetectorClassification.MEDIUM
    CONFIDENCE = DetectorClassification.EXACTLY

    WIKI = 'https://github.com/SmartContractTools/SmartFast/wiki/Detector-Documentation#contracts-that-lock-ether'


    WIKI_TITLE = 'Contracts that lock Ether'
    WIKI_DESCRIPTION = 'Contract with a `payable` function, but without a withdrawal capacity.'
    WIKI_EXPLOIT_SCENARIO = '''
```solidity
pragma solidity 0.4.24;
contract Locked{
    function receive() payable public{
    }
}
```
Every Ether sent to `Locked` will be lost.'''

    WIKI_RECOMMENDATION = 'Remove the payable attribute or add a withdraw function.'

    @staticmethod
    def do_no_send_ether(contract):
        assignvalue_base = {}
        # print("----------")
        # print(contract.name)
        # if contract.inheritance:
        #     print([v.name for v in contract.inheritance])
        functions = contract.all_functions_called
        # print([v.function_type == FunctionType.CONSTRUCTOR_VARIABLES or v.function_type == FunctionType.CONSTRUCTOR_CONSTANT_VARIABLES for v in functions])
        to_explore = functions
        explored = []
        while to_explore:
            functions = to_explore
            explored += to_explore
            to_explore = []
            for function in functions:
                if function.function_type == FunctionType.CONSTRUCTOR_VARIABLES or function.function_type == FunctionType.CONSTRUCTOR_CONSTANT_VARIABLES or function.is_constructor:
                    calls = [c.name for c in function.internal_calls]
                    if 'suicide(address)' in calls or 'selfdestruct(address)' in calls:
                        return False
                    for node in function.nodes:
                        for ir in node.irs:
                            if isinstance(ir, Assignment):
                                if ir.lvalue.name in assignvalue_base.keys():
                                    assignvalue_base.pop(ir.lvalue.name)
                                if ir.rvalue.name in assignvalue_base.keys():
                                    assignvalue_base[ir.lvalue.name] = assignvalue_base[ir.rvalue.name]
                                else:
                                    assignvalue_base[ir.lvalue.name] = ir.rvalue
                                    # print(type(ir.rvalue))
                            elif isinstance(ir, Unpack):
                                unpack_lvalue = ir._lvalue
                                if unpack_lvalue.name in assignvalue_base.keys():
                                    assignvalue_base.pop(ir.lvalue.name)
                            if isinstance(ir, (Send, Transfer, HighLevelCall, LowLevelCall, NewContract)):
                                if ir.call_value and not((isinstance(ir.call_value, Constant) and ir.call_value == 0) or (ir.call_value.name in assignvalue_base.keys() and isinstance(assignvalue_base[ir.call_value.name], Constant) and assignvalue_base[ir.call_value.name] == 0)):
                                    return False
                            if isinstance(ir, (LowLevelCall)):
                                if ir.function_name in ['delegatecall', 'callcode']:
                                    return False
                            if isinstance(ir, (InternalCall, LibraryCall)):
                                if not ir.function in explored:
                                    to_explore.append(ir.function)
            for function in functions:
                if function.function_type == FunctionType.CONSTRUCTOR_VARIABLES or function.function_type == FunctionType.CONSTRUCTOR_CONSTANT_VARIABLES or function.is_constructor:
                    continue
                assignvalue = {}
                for v,m in assignvalue_base.items():
                    assignvalue[v] = m
                # assignvalue = copy.deepcopy(assignvalue_base)
                # print(function.name)
                # print(function.type)
                # print("------")
                calls = [c.name for c in function.internal_calls]
                # print(calls)
                if 'suicide(address)' in calls or 'selfdestruct(address)' in calls:
                    return False
                for node in function.nodes:
                    # print(node)
                    for ir in node.irs:
                        # print(ir)
                        # print(type(ir))
                        if isinstance(ir, Assignment):
                            if ir.lvalue.name in assignvalue.keys():
                                assignvalue.pop(ir.lvalue.name)
                            if ir.rvalue.name in assignvalue.keys():
                                assignvalue[ir.lvalue.name] = assignvalue[ir.rvalue.name]
                            else:
                                assignvalue[ir.lvalue.name] = ir.rvalue
                        elif isinstance(ir, Unpack):
                            unpack_lvalue = ir._lvalue
                            # print(unpack_lvalue.type)
                            # if isinstance(unpack_lvalue, Constant):
                            #     print(unpack_lvalue.value)
                            #     print("***********")
                            if unpack_lvalue.name in assignvalue.keys():
                                assignvalue.pop(ir.lvalue.name)
                            # print(unpack_lvalue.name)
                            # print("-----------------")
                            
                        # print(len(assignvalue))
                        if isinstance(ir, (Send, Transfer, HighLevelCall, LowLevelCall, NewContract)):
                            # if ir.call_value:
                            #     print("ir.call_value")
                            #     print(ir.call_value.name)
                            #     print(ir.call_value)
                            #     print(type(ir.call_value))
                            #     print(ir.call_value.type)
                            #     print(ir.call_value == 0)
                            # print("assignvalue:")
                            # for key in assignvalue.keys():
                            #     print(key)
                            #     print(assignvalue[key])
                            # if ir.call_value:
                            #     print(ir.call_value.name in assignvalue.keys())
                            #     if ir.call_value.name in assignvalue.keys():
                            #         print(assignvalue[ir.call_value.name] != 0)
                            if ir.call_value and not((isinstance(ir.call_value, Constant) and ir.call_value == 0) or (ir.call_value.name in assignvalue.keys() and isinstance(assignvalue[ir.call_value.name], Constant) and assignvalue[ir.call_value.name] == 0)):
                                # print("************wa**********")
                                return False
                        if isinstance(ir, (LowLevelCall)):
                            if ir.function_name in ['delegatecall', 'callcode']:
                                return False
                        # If a new internal call or librarycall
                        # Add it to the list to explore
                        # InternalCall if to follow internal call in libraries
                        if isinstance(ir, (InternalCall, LibraryCall)):
                            if not ir.function in explored:
                                to_explore.append(ir.function)

        return True


    def _detect(self):
        results = []

        for contract in self.smartfast.contracts:
            if contract.is_signature_only():
                continue
            funcs_payable = [function for function in contract.functions if function.payable]
            if funcs_payable:
                if self.do_no_send_ether(contract):
                    info = [f"Contract locking ether found in {self.filename}:\n"]
                    info += ["\tContract ", contract, " has payable functions:\n"]
                    for function in funcs_payable:
                        info += [f"\t - ", function, "\n"]
                    info += "\tBut does not have a function to withdraw the ether or the call value is 0\n"

                    json = self.generate_result(info)

                    results.append(json)

        return results
