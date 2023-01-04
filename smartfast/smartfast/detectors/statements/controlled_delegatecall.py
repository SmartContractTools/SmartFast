from smartfast.detectors.abstract_detector import AbstractDetector, DetectorClassification
from smartfast.smartir.operations import LowLevelCall,SolidityCall,Condition,Binary,Assignment,TypeConversion,Unpack
from smartfast.analyses.data_dependency.data_dependency import is_tainted
from smartfast.core.declarations import SolidityFunction
from smartfast.core.declarations.function import Function, FunctionType
import copy

class ControlledDelegateCall(AbstractDetector):
    """
    """

    ARGUMENT = 'controlled-delegatecall'
    HELP = 'Controlled delegatecall destination'
    IMPACT = DetectorClassification.HIGH
    CONFIDENCE = DetectorClassification.PROBABLY

    WIKI = 'https://github.com/SmartContractTools/SmartFast/wiki/Detector-Documentation#controlled-delegatecall'


    WIKI_TITLE = 'Controlled Delegatecall'
    WIKI_DESCRIPTION = '`Delegatecall` or `callcode` to an address controlled by the user.'
    WIKI_EXPLOIT_SCENARIO = '''
```solidity
contract Delegatecall{
    function delegate(address to, bytes data){
        to.delegatecall(data);
    }
}
```
Bob calls `delegate` and delegates the execution to his malicious contract. As a result, Bob withdraws the funds of the contract and destructs it.'''

    WIKI_RECOMMENDATION = 'Avoid using `delegatecall`. Use only trusted destinations.'

    def controlled_delegatecall(self, contract):
        results = []
        check_taints_base = []
        msgsender_base = []
        for f in contract.functions:
            if_protected = False;
            if f.function_type == FunctionType.CONSTRUCTOR_VARIABLES or f.function_type == FunctionType.CONSTRUCTOR_CONSTANT_VARIABLES or f.is_constructor:
                ret = []
                # If its an upgradeable proxy, do not report protected function
                # As functions to upgrades the destination lead to too many FPs
                if contract.is_upgradeable_proxy and f.is_protected():
                    continue
                for modifier in f.modifiers:
                    for node in modifier.nodes:
                        binary_operation = []
                        # if node.type
                        for ir in node.irs:
                            if isinstance(ir, Binary):
                                binary_operation.extend([v.name for v in ir.read])
                                binary_operation.append(ir.lvalue.name)
                            elif isinstance(ir, Assignment):
                                assig_rvalue = ir.rvalue.name
                                assig_lvalue = ir._lvalue.name
                                if assig_lvalue in msgsender_base:
                                    msgsender_base.remove(assig_lvalue)
                                if assig_rvalue == 'msg.sender':
                                    msgsender_base.append(assig_lvalue)
                                elif assig_rvalue in msgsender_base:
                                    msgsender_base.append(assig_lvalue)
                                if assig_lvalue in check_taints_base:
                                    check_taints_base.remove(assig_lvalue)
                                if assig_rvalue in check_taints_base:
                                    check_taints_base.append(assig_lvalue)
                            elif isinstance(ir, TypeConversion):
                                variable_read = ir.variable.name
                                if variable_read in check_taints_base:
                                    check_taints_base.append(ir.lvalue.name)
                                if variable_read in msgsender_base:
                                    msgsender_base.append(ir.lvalue.name)
                            elif isinstance(ir, Unpack):
                                unpack_lvalue = ir._lvalue
                                if unpack_lvalue.name in check_taints_base:
                                    check_taints_base.remove(unpack_lvalue.name)
                                if unpack_lvalue.name in msgsender_base:
                                    msgsender_base.remove(unpack_lvalue.name)
                            elif isinstance(ir, SolidityCall) and\
                                    isinstance(ir.function, SolidityFunction) and\
                                    ir.function.full_name in ['require(bool)', 'assert(bool)']:
                                        if set(binary_operation).intersection([v.name for v in ir.arguments]):
                                            check_taints_base.extend(binary_operation)
                                        if 'msg.sender' in check_taints_base or set(check_taints_base).intersection(msgsender_base):
                                            if_protected = True
                            elif isinstance(ir, Condition):
                                if ir.value.name in binary_operation:
                                    check_taints_base.extend(binary_operation)
                                if 'msg.sender' in check_taints_base or set(check_taints_base).intersection(msgsender_base):
                                    if_protected = True
                for node in f.nodes:
                    # print(node)
                    # print(type(node))
                    binary_operation = []
                    for ir in node.irs:
                        if isinstance(ir, Binary):
                            binary_operation.extend([v.name for v in ir.read])
                            binary_operation.append(ir.lvalue.name)
                        elif isinstance(ir, Assignment):
                            assig_rvalue = ir.rvalue.name
                            assig_lvalue = ir._lvalue.name
                            if assig_lvalue in msgsender_base:
                                msgsender_base.remove(assig_lvalue)
                            if assig_rvalue == 'msg.sender':
                                msgsender_base.append(assig_lvalue)
                            elif assig_rvalue in msgsender_base:
                                msgsender_base.append(assig_lvalue)
                            if assig_lvalue in check_taints_base:
                                check_taints_base.remove(assig_lvalue)
                            if assig_rvalue in check_taints_base:
                                check_taints_base.append(assig_lvalue)
                        elif isinstance(ir, TypeConversion):
                            variable_read = ir.variable.name
                            if variable_read in check_taints_base:
                                check_taints_base.append(ir.lvalue.name)
                            if variable_read in msgsender_base:
                                msgsender_base.append(ir.lvalue.name)
                        elif isinstance(ir, Unpack):
                            unpack_lvalue = ir._lvalue
                            if unpack_lvalue.name in check_taints_base:
                                check_taints_base.remove(unpack_lvalue.name)
                            if unpack_lvalue.name in msgsender_base:
                                msgsender_base.remove(unpack_lvalue.name)
                        elif isinstance(ir, SolidityCall) and\
                                isinstance(ir.function, SolidityFunction) and\
                                ir.function.full_name in ['require(bool)', 'assert(bool)']:
                                    if set(binary_operation).intersection([v.name for v in ir.arguments]):
                                        check_taints_base.extend(binary_operation)
                                    if 'msg.sender' in check_taints_base or set(check_taints_base).intersection(msgsender_base):
                                        if_protected = True
                        elif isinstance(ir, Condition):
                            if ir.value.name in binary_operation:
                                check_taints_base.extend(binary_operation)
                            if 'msg.sender' in check_taints_base or set(check_taints_base).intersection(msgsender_base):
                                if_protected = True
                        elif isinstance(ir, LowLevelCall) and ir.function_name in ['delegatecall', 'callcode']:
                            if is_tainted(ir.destination,
                                          f.contract) and ir.destination.name not in check_taints_base and not if_protected:
                                ret.append(node)
                        # print(check_taints_base)

        for f in contract.functions:
            if_protected = False;
            if f.function_type == FunctionType.CONSTRUCTOR_VARIABLES or f.function_type == FunctionType.CONSTRUCTOR_CONSTANT_VARIABLES or f.is_constructor:
                continue
            # print(f.name)
            check_taints = copy.deepcopy(check_taints_base)
            msgsender = copy.deepcopy(msgsender_base)
            # print("check_taints")
            # print(check_taints)
            # print("check_taints_base")
            # print(check_taints_base)
            ret = []
            # If its an upgradeable proxy, do not report protected function
            # As functions to upgrades the destination lead to too many FPs
            if contract.is_upgradeable_proxy and f.is_protected():
                continue
            for modifier in f.modifiers:
                for node in modifier.nodes:
                    binary_operation = []
                    # if node.type
                    for ir in node.irs:
                        if isinstance(ir, Binary):
                            binary_operation.extend([v.name for v in ir.read])
                            binary_operation.append(ir.lvalue.name)
                        elif isinstance(ir, Assignment):
                            assig_rvalue = ir.rvalue.name
                            assig_lvalue = ir._lvalue.name
                            if assig_lvalue in msgsender:
                                msgsender.remove(assig_lvalue)
                            if assig_rvalue == 'msg.sender':
                                msgsender.append(assig_lvalue)
                            elif assig_rvalue in msgsender:
                                msgsender.append(assig_lvalue)
                            if assig_lvalue in check_taints:
                                check_taints.remove(assig_lvalue)
                            if assig_rvalue in check_taints:
                                check_taints.append(assig_lvalue)
                        elif isinstance(ir, TypeConversion):
                            variable_read = ir.variable.name
                            if variable_read in check_taints:
                                check_taints.append(ir.lvalue.name)
                            if variable_read in msgsender:
                                msgsender.append(ir.lvalue.name)
                        elif isinstance(ir, Unpack):
                            unpack_lvalue = ir._lvalue
                            if unpack_lvalue.name in check_taints:
                                check_taints.remove(unpack_lvalue.name)
                            if unpack_lvalue.name in msgsender:
                                msgsender.remove(unpack_lvalue.name)
                        elif isinstance(ir, SolidityCall) and\
                                isinstance(ir.function, SolidityFunction) and\
                                ir.function.full_name in ['require(bool)', 'assert(bool)']:
                                    if set(binary_operation).intersection([v.name for v in ir.arguments]):
                                        check_taints.extend(binary_operation)
                                    if 'msg.sender' in check_taints or set(check_taints).intersection(msgsender):
                                        if_protected = True
                        elif isinstance(ir, Condition):
                            if ir.value.name in binary_operation:
                                check_taints.extend(binary_operation)
                            if 'msg.sender' in check_taints or set(check_taints).intersection(msgsender):
                                if_protected = True
            for node in f.nodes:
                # print(node)
                # print(type(node))
                binary_operation = []
                for ir in node.irs:
                    # print(ir)
                    # print(msgsender)
                    # print(if_protected)
                    if isinstance(ir, Binary):
                        binary_operation.extend([v.name for v in ir.read])
                        binary_operation.append(ir.lvalue.name)
                    elif isinstance(ir, Assignment):
                        assig_rvalue = ir.rvalue.name
                        assig_lvalue = ir._lvalue.name
                        if assig_lvalue in msgsender:
                            msgsender.remove(assig_lvalue)
                        if assig_rvalue == 'msg.sender':
                            msgsender.append(assig_lvalue)
                        elif assig_rvalue in msgsender:
                            msgsender.append(assig_lvalue)
                        if assig_lvalue in check_taints:
                            check_taints.remove(assig_lvalue)
                        if assig_rvalue in check_taints:
                            check_taints.append(assig_lvalue)
                    elif isinstance(ir, TypeConversion):
                        variable_read = ir.variable.name
                        if variable_read in check_taints:
                            check_taints.append(ir.lvalue.name)
                        if variable_read in msgsender:
                            msgsender.append(ir.lvalue.name)
                    elif isinstance(ir, Unpack):
                        unpack_lvalue = ir._lvalue
                        if unpack_lvalue.name in check_taints:
                            check_taints.remove(unpack_lvalue.name)
                        if unpack_lvalue.name in msgsender:
                            msgsender.remove(unpack_lvalue.name)
                    elif isinstance(ir, SolidityCall) and\
                            isinstance(ir.function, SolidityFunction) and\
                            ir.function.full_name in ['require(bool)', 'assert(bool)']:
                                if set(binary_operation).intersection([v.name for v in ir.arguments]):
                                    check_taints.extend(binary_operation)
                                if 'msg.sender' in check_taints or set(check_taints).intersection(msgsender):
                                    if_protected = True
                    elif isinstance(ir, Condition):
                        if ir.value.name in binary_operation:
                            check_taints.extend(binary_operation)
                        if 'msg.sender' in check_taints or set(check_taints).intersection(msgsender):
                            if_protected = True
                    elif isinstance(ir, LowLevelCall) and ir.function_name in ['delegatecall', 'callcode']:
                        if is_tainted(ir.destination,
                                      f.contract) and ir.destination.name not in check_taints and not if_protected:
                            ret.append(node)
            if ret:
                results.append((f,ret))
        return results

    def _detect(self):
        results = []

        for contract in self.smartfast.contracts_derived:
            controlled_delegatecall_values = self.controlled_delegatecall(contract)
            if controlled_delegatecall_values:
                for (f, nodes) in controlled_delegatecall_values:
                    func_info = [f, ' uses delegatecall to a input-controlled function id\n']

                    for node in nodes:
                        node_info = func_info + ['\t- ', node,'\n']
                        res = self.generate_result(node_info)
                        results.append(res)

        return results
