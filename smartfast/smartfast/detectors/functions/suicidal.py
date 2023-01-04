"""
Module detecting suicidal contract

A suicidal contract is an unprotected function that calls selfdestruct
"""

from smartfast.detectors.abstract_detector import AbstractDetector, DetectorClassification
from smartfast.core.declarations.function import Function, FunctionType
from smartfast.smartir.operations import (SolidityCall,Assignment,TypeConversion,Unpack,Binary,Condition)
from smartfast.core.declarations.solidity_variables import (SolidityFunction,
                                                          SolidityVariableComposed)
import copy

class Suicidal(AbstractDetector):
    """
    Unprotected function detector
    """

    ARGUMENT = 'suicidal'
    HELP = 'Functions allowing anyone to destruct the contract'
    IMPACT = DetectorClassification.HIGH
    CONFIDENCE = DetectorClassification.EXACTLY

    WIKI = 'https://github.com/SmartContractTools/SmartFast/wiki/Detector-Documentation#suicidal'


    WIKI_TITLE = 'Suicidal'
    WIKI_DESCRIPTION = 'Unprotected call to a function executing `selfdestruct`/`suicide`.'
    WIKI_EXPLOIT_SCENARIO = '''
```solidity
contract Suicidal{
    function kill() public{
        selfdestruct(msg.sender);
    }
}
```
Bob calls `kill` and destructs the contract.'''

    WIKI_RECOMMENDATION = 'Protect access to all sensitive functions.'

    @staticmethod
    def detect_suicidal_func_bedin(func,check_taints,tainted_sender):
        """ Detect if the function is suicidal

        Detect the public functions calling suicide/selfdestruct without protection
        Returns:
            (bool): True if the function is suicidal
        """

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
                        if variable_read in check_taints:
                            check_taints.append(ir.lvalue.name)
                        if variable_read in tainted_sender:
                            tainted_sender.append(ir.lvalue.name)
                    elif isinstance(ir, Unpack):
                        unpack_lvalue = ir._lvalue
                        if unpack_lvalue.name in check_taints:
                            check_taints.remove(unpack_lvalue.name)
                        if unpack_lvalue.name in tainted_sender:
                            tainted_sender.remove(unpack_lvalue.name)
                    elif isinstance(ir, SolidityCall):
                        if isinstance(ir.function, SolidityFunction) and\
                            ir.function.full_name in ['suicide(address)', 'selfdestruct(address)']:
                                return True
                        if isinstance(ir.function, SolidityFunction) and\
                            ir.function.full_name in ['require(bool)', 'assert(bool)']:
                                if set(binary_operation).intersection([v.name for v in ir.arguments]):
                                    check_taints.extend(binary_operation)
                                if 'msg.sender' in check_taints or set(check_taints).intersection(tainted_sender):
                                    # print(node)
                                    return False
                    elif isinstance(ir, Condition):
                        if ir.value.name in binary_operation:
                            check_taints.extend(binary_operation)
                        if 'msg.sender' in check_taints or set(check_taints).intersection(tainted_sender):
                            return False
        for node in func.nodes:
            # print(node)
            binary_operation = []
            for ir in node.irs:
                if isinstance(ir, Binary):
                    binary_operation.extend([v.name for v in ir.read])
                    binary_operation.append(ir.lvalue.name)
                elif isinstance(ir,Assignment):
                    assig_rvalue = ir.rvalue
                    assig_lvalue = ir._lvalue.name
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
                    if variable_read in check_taints:
                        check_taints.append(ir.lvalue.name)
                    if variable_read in tainted_sender:
                        tainted_sender.append(ir.lvalue.name)
                elif isinstance(ir, Unpack):
                    unpack_lvalue = ir._lvalue
                    if unpack_lvalue.name in check_taints:
                        check_taints.remove(unpack_lvalue.name)
                    if unpack_lvalue.name in tainted_sender:
                        tainted_sender.remove(unpack_lvalue.name)
                elif isinstance(ir, SolidityCall):
                    if isinstance(ir.function, SolidityFunction) and\
                        ir.function.full_name in ['suicide(address)', 'selfdestruct(address)']:
                            return True
                    if isinstance(ir.function, SolidityFunction) and\
                        ir.function.full_name in ['require(bool)', 'assert(bool)']:
                            if set(binary_operation).intersection([v.name for v in ir.arguments]):
                                check_taints.extend(binary_operation)
                            if 'msg.sender' in check_taints or set(check_taints).intersection(tainted_sender):
                                return False
                elif isinstance(ir, Condition):
                    if ir.value.name in binary_operation:
                        check_taints.extend(binary_operation)
                    if 'msg.sender' in check_taints or set(check_taints).intersection(tainted_sender):
                        return False               

        return False

    @staticmethod
    def detect_suicidal_func(func,check_taints,tainted_sender):
        """ Detect if the function is suicidal

        Detect the public functions calling suicide/selfdestruct without protection
        Returns:
            (bool): True if the function is suicidal
        """

        if func.is_constructor:
            return False

        if func.visibility not in ['public', 'external']:
            return False

        calls = [c.name for c in func.internal_calls]
        if not ('suicide(address)' in calls or 'selfdestruct(address)' in calls):
            return False

        if func.is_protected():
            return False

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
                        if variable_read in check_taints:
                            check_taints.append(ir.lvalue.name)
                        if variable_read in tainted_sender:
                            tainted_sender.append(ir.lvalue.name)
                    elif isinstance(ir, Unpack):
                        unpack_lvalue = ir._lvalue
                        if unpack_lvalue.name in check_taints:
                            check_taints.remove(unpack_lvalue.name)
                        if unpack_lvalue.name in tainted_sender:
                            tainted_sender.remove(unpack_lvalue.name)
                    elif isinstance(ir, SolidityCall):
                        if isinstance(ir.function, SolidityFunction) and\
                            ir.function.full_name in ['suicide(address)', 'selfdestruct(address)']:
                                return True
                        if isinstance(ir.function, SolidityFunction) and\
                            ir.function.full_name in ['require(bool)', 'assert(bool)']:
                                if set(binary_operation).intersection([v.name for v in ir.arguments]):
                                    check_taints.extend(binary_operation)
                                if 'msg.sender' in check_taints or set(check_taints).intersection(tainted_sender):
                                    # print(node)
                                    return False
                    elif isinstance(ir, Condition):
                        if ir.value.name in binary_operation:
                            check_taints.extend(binary_operation)
                        if 'msg.sender' in check_taints or set(check_taints).intersection(tainted_sender):
                            return False
        for node in func.nodes:
            # print(node)
            binary_operation = []
            for ir in node.irs:
                if isinstance(ir, Binary):
                    binary_operation.extend([v.name for v in ir.read])
                    binary_operation.append(ir.lvalue.name)
                elif isinstance(ir,Assignment):
                    assig_rvalue = ir.rvalue
                    assig_lvalue = ir._lvalue.name
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
                    if variable_read in check_taints:
                        check_taints.append(ir.lvalue.name)
                    if variable_read in tainted_sender:
                        tainted_sender.append(ir.lvalue.name)
                elif isinstance(ir, Unpack):
                    unpack_lvalue = ir._lvalue
                    if unpack_lvalue.name in check_taints:
                        check_taints.remove(unpack_lvalue.name)
                    if unpack_lvalue.name in tainted_sender:
                        tainted_sender.remove(unpack_lvalue.name)
                elif isinstance(ir, SolidityCall):
                    if isinstance(ir.function, SolidityFunction) and\
                        ir.function.full_name in ['suicide(address)', 'selfdestruct(address)']:
                            return True
                    if isinstance(ir.function, SolidityFunction) and\
                        ir.function.full_name in ['require(bool)', 'assert(bool)']:
                            if set(binary_operation).intersection([v.name for v in ir.arguments]):
                                check_taints.extend(binary_operation)
                            if 'msg.sender' in check_taints or set(check_taints).intersection(tainted_sender):
                                return False
                elif isinstance(ir, Condition):
                    if ir.value.name in binary_operation:
                        check_taints.extend(binary_operation)
                    if 'msg.sender' in check_taints or set(check_taints).intersection(tainted_sender):
                        return False               

        return True

    def detect_suicidal(self, contract):
        ret = []

        check_taints = []
        tainted_sender = []

        for f in contract.functions:
            if f.function_type == FunctionType.CONSTRUCTOR_VARIABLES or f.function_type == FunctionType.CONSTRUCTOR_CONSTANT_VARIABLES or f.is_constructor:
                if self.detect_suicidal_func_bedin(f,check_taints,tainted_sender):
                    ret.append(f)

        for f in contract.functions_declared:
            if f.function_type == FunctionType.CONSTRUCTOR_VARIABLES or f.function_type == FunctionType.CONSTRUCTOR_CONSTANT_VARIABLES or f.is_constructor:
                continue
            if self.detect_suicidal_func(f,copy.deepcopy(check_taints),copy.deepcopy(tainted_sender)):
                ret.append(f)
        return ret

    def _detect(self):
        """ Detect the suicidal functions
        """
        results = []
        for c in self.contracts:
            functions = self.detect_suicidal(c)
            for func in functions:

                info = [func, " allows anyone to destruct the contract\n"]

                res = self.generate_result(info)

                results.append(res)

        return results
