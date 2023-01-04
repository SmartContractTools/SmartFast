"""
    Module detecting send to arbitrary address

    To avoid FP, it does not report:
        - If msg.sender is used as index (withdraw situation)
        - If the function is protected
        - If the value sent is msg.value (repay situation)
        - If there is a call to transferFrom

    TODO: dont report if the value is tainted by msg.value
"""
from smartfast.core.declarations import Function
from smartfast.analyses.data_dependency.data_dependency import is_tainted, is_dependent
from smartfast.core.declarations.solidity_variables import (SolidityFunction,
                                                          SolidityVariableComposed)
from smartfast.detectors.abstract_detector import (AbstractDetector,
                                                 DetectorClassification)
from smartfast.smartir.operations import (HighLevelCall, Index, LowLevelCall,
                                        Send, SolidityCall, Transfer,Assignment,TypeConversion,Unpack,Binary,Condition)
from smartfast.smartir.variables import Constant
from smartfast.core.declarations.function import Function, FunctionType
import copy

class ArbitrarySend(AbstractDetector):
    """
    """

    ARGUMENT = 'arbitrary-send'
    HELP = 'Functions that send Ether to arbitrary destinations'
    IMPACT = DetectorClassification.HIGH
    CONFIDENCE = DetectorClassification.PROBABLY

    WIKI = 'https://github.com/SmartContractTools/SmartFast/wiki/Detector-Documentation#functions-that-send-ether-to-arbitrary-destinations'

    WIKI_TITLE = 'Functions that send Ether to arbitrary destinations'
    WIKI_DESCRIPTION = 'Unprotected call to a function sending Ether to an arbitrary address.'
    WIKI_EXPLOIT_SCENARIO = '''
```solidity
contract ArbitrarySend{
    address destination;
    function setDestination(){
        destination = msg.sender;
    }

    function withdraw() public{
        destination.transfer(this.balance);
    }
}
```
Bob calls `setDestination` and `withdraw`. As a result he withdraws the contract's balance.'''

    WIKI_RECOMMENDATION = 'Ensure that an arbitrary user cannot withdraw unauthorized funds.'

    def arbitrary_send(self, func, tainted_value_zero, tainted_sender, check_taints):
        """
        """
        if func.is_protected():
            return []
        if_protected = False;
        ret = []
        for modifier in func.modifiers:
            for node in modifier.nodes:
                # print(node)
                binary_operation = []
                # if node.type
                for ir in node.irs:
                    # print(ir)
                    if isinstance(ir, Binary):
                        binary_operation.extend([v.name for v in ir.read])
                        binary_operation.append(ir.lvalue.name)
                    elif isinstance(ir,Assignment):
                        assig_rvalue = ir.rvalue
                        assig_lvalue = ir._lvalue.name
                        if assig_lvalue in tainted_value_zero:
                            tainted_value_zero.remove(assig_lvalue)
                        if isinstance(assig_rvalue,Constant) and assig_rvalue.value == 0:
                            tainted_value_zero.append(assig_lvalue)
                        elif assig_rvalue.name in tainted_value_zero:
                            tainted_value_zero.append(assig_lvalue)
                        if assig_lvalue in tainted_sender:
                            tainted_sender.remove(assig_lvalue)
                        if assig_rvalue == SolidityVariableComposed('msg.sender'):
                            tainted_sender.append(assig_lvalue)
                        elif assig_rvalue.name in tainted_sender:
                            tainted_sender.append(assig_lvalue)
                        if assig_lvalue in check_taints:
                            check_taints.remove(assig_lvalue)
                        if assig_rvalue.name in check_taints:
                            check_taints.append(assig_lvalue)
                    elif isinstance(ir, TypeConversion):
                        variable_read = ir.variable.name
                        if variable_read in tainted_value_zero:
                            tainted_value_zero.append(ir.lvalue.name)
                        if variable_read in check_taints:
                            check_taints.append(ir.lvalue.name)
                        if variable_read in tainted_sender:
                            tainted_sender.append(ir.lvalue.name)
                    elif isinstance(ir, Unpack):
                        unpack_lvalue = ir._lvalue
                        if unpack_lvalue.name in tainted_value_zero:
                            tainted_value_zero.remove(unpack_lvalue.name)
                        if unpack_lvalue.name in check_taints:
                            check_taints.remove(unpack_lvalue.name)
                        if unpack_lvalue.name in tainted_sender:
                            tainted_sender.remove(unpack_lvalue.name)
                    elif isinstance(ir, SolidityCall):
                        if ir.function == SolidityFunction('ecrecover(bytes32,uint8,bytes32,bytes32)'):
                            return False
                        if isinstance(ir.function, SolidityFunction) and\
                            ir.function.full_name in ['require(bool)', 'assert(bool)']:
                                if set(binary_operation).intersection([v.name for v in ir.arguments]):
                                    check_taints.extend(binary_operation)
                                if 'msg.sender' in check_taints or set(check_taints).intersection(tainted_sender):
                                    # print(node)
                                    if_protected = True
                    elif isinstance(ir, Index):
                        if ir.variable_right == SolidityVariableComposed('msg.sender'):
                            return False
                        if is_dependent(ir.variable_right, SolidityVariableComposed('msg.sender'), func.contract):
                            return False
                    elif isinstance(ir, Condition):
                        if ir.value.name in binary_operation:
                            check_taints.extend(binary_operation)
                        if 'msg.sender' in check_taints or set(check_taints).intersection(tainted_sender):
                            if_protected = True
        for node in func.nodes:
            # print(node)
            binary_operation = []
            for ir in node.irs:
                # print(ir)
                if isinstance(ir, Binary):
                    binary_operation.extend([v.name for v in ir.read])
                    binary_operation.append(ir.lvalue.name)
                elif isinstance(ir,Assignment):
                    assig_rvalue = ir.rvalue
                    assig_lvalue = ir._lvalue.name
                    if assig_lvalue in tainted_value_zero:
                        tainted_value_zero.remove(assig_lvalue)
                    if isinstance(assig_rvalue,Constant) and assig_rvalue.value == 0:
                        tainted_value_zero.append(assig_lvalue)
                    elif assig_rvalue.name in tainted_value_zero:
                        tainted_value_zero.append(assig_lvalue)
                    if assig_lvalue in tainted_sender:
                        tainted_sender.remove(assig_lvalue)
                    if assig_rvalue == SolidityVariableComposed('msg.sender'):
                        tainted_sender.append(assig_lvalue)
                    elif assig_rvalue.name in tainted_sender:
                        tainted_sender.append(assig_lvalue)
                    if assig_lvalue in check_taints:
                        check_taints.remove(assig_lvalue)
                    if assig_rvalue.name in check_taints:
                        check_taints.append(assig_lvalue)
                elif isinstance(ir, TypeConversion):
                    variable_read = ir.variable.name
                    if variable_read in tainted_value_zero:
                        tainted_value_zero.append(ir.lvalue.name)
                    if variable_read in check_taints:
                        check_taints.append(ir.lvalue.name)
                    if variable_read in tainted_sender:
                        tainted_sender.append(ir.lvalue.name)
                elif isinstance(ir, Unpack):
                    unpack_lvalue = ir._lvalue
                    if unpack_lvalue.name in tainted_value_zero:
                        tainted_value_zero.remove(unpack_lvalue.name)
                    if unpack_lvalue.name in check_taints:
                        check_taints.remove(unpack_lvalue.name)
                    if unpack_lvalue.name in tainted_sender:
                        tainted_sender.remove(unpack_lvalue.name)
                elif isinstance(ir, SolidityCall):
                    if ir.function == SolidityFunction('ecrecover(bytes32,uint8,bytes32,bytes32)'):
                        return False
                    if isinstance(ir.function, SolidityFunction) and\
                        ir.function.full_name in ['require(bool)', 'assert(bool)']:
                            if set(binary_operation).intersection([v.name for v in ir.arguments]):
                                check_taints.extend(binary_operation)
                            if 'msg.sender' in check_taints or set(check_taints).intersection(tainted_sender):
                                if_protected = True
                elif isinstance(ir, Index):
                    if ir.variable_right == SolidityVariableComposed('msg.sender'):
                        return False
                    if is_dependent(ir.variable_right, SolidityVariableComposed('msg.sender'), func.contract):
                        return False
                elif isinstance(ir, Condition):
                    if ir.value.name in binary_operation:
                        check_taints.extend(binary_operation)
                    if 'msg.sender' in check_taints or set(check_taints).intersection(tainted_sender):
                        if_protected = True
                if isinstance(ir, (HighLevelCall, LowLevelCall, Transfer, Send)):
                    if isinstance(ir, (HighLevelCall)):
                        if isinstance(ir.function, Function):
                            if ir.function.full_name == 'transferFrom(address,address,uint256)':
                                return False
                    if ir.call_value is None:
                        continue
                    # print(ir.call_value.name)
                    if (isinstance(ir.call_value,Constant) and ir.call_value.value == 0) or ir.call_value.name in tainted_value_zero:
                        continue
                    if ir.call_value == SolidityVariableComposed('msg.value'):
                        continue
                    if is_dependent(ir.call_value, SolidityVariableComposed('msg.value'), func.contract):
                        continue
                    if is_tainted(ir.destination, func.contract) and ir.destination.name not in check_taints and not if_protected:
                        ret.append(node)

        return ret


    def detect_arbitrary_send(self, contract):
        """
            Detect arbitrary send
        Args:
            contract (Contract)
        Returns:
            list((Function), (list (Node)))
        """
        result = []
        check_taints = []
        tainted_value_zero = []
        tainted_sender = []
        for f in contract.functions:
            if f.function_type == FunctionType.CONSTRUCTOR_VARIABLES or f.function_type == FunctionType.CONSTRUCTOR_CONSTANT_VARIABLES or f.is_constructor:
                nodes = self.arbitrary_send(f,tainted_value_zero,tainted_sender,check_taints)
                if nodes:
                    result.append((f, nodes))

        for f in contract.functions_declared:
            if f.function_type == FunctionType.CONSTRUCTOR_VARIABLES or f.function_type == FunctionType.CONSTRUCTOR_CONSTANT_VARIABLES or f.is_constructor:
                continue
            nodes = self.arbitrary_send(f,copy.deepcopy(tainted_value_zero),copy.deepcopy(tainted_sender),copy.deepcopy(check_taints))
            if nodes:
                result.append((f, nodes))
        return result

    def _detect(self):
        """
        """
        results = []

        for c in self.contracts:
            # print(c.name)
            arbitrary_send = self.detect_arbitrary_send(c)
            for (func, nodes) in arbitrary_send:

                info = [func, " sends eth to arbitrary user\n"]
                info += ['\tDangerous calls:\n']
                for node in nodes:
                    info += ['\t- ', node, '\n']

                res = self.generate_result(info)

                results.append(res)

        return results
