from smartfast.detectors.abstract_detector import AbstractDetector, DetectorClassification
from smartfast.core.cfg.node import NodeType
from smartfast.smartir.operations import (Assignment,Unpack,Binary,TypeConversion,BinaryType,Send,Transfer,Call)
from smartfast.smartir.variables.constant import Constant
from smartfast.core.declarations.function import Function, FunctionType
from smartfast.core.solidity_types.elementary_type import ElementaryType
import copy


class Transfertozeroaddress(AbstractDetector):
    """
    Detect function named backdoor
    """

    ARGUMENT = 'transfer-to-zeroaddress'  # smartfast will launch the detector with smartfast.py --mydetector
    HELP = 'The withdrawal address is 0x0'
    IMPACT = DetectorClassification.LOW
    CONFIDENCE = DetectorClassification.EXACTLY


    WIKI = 'https://github.com/trailofbits/smartfast/wiki/Transfertozeroaddress'
    WIKI_TITLE = 'Transfertozeroaddress'
    WIKI_DESCRIPTION = 'Withdrawal address is 0x0, no check.'
    WIKI_EXPLOIT_SCENARIO = '''
```solidity
contract Transfertozeroaddress {
    address owner;
    function bad() {
        address aa = 0x0;
        aa.transfer(msg.value);
    }
    function good() {
        address aa = 0x0;
        if(aa != 0x0) {revert();}
        aa.transfer(msg.value);
    }
}
```'''
    WIKI_RECOMMENDATION = 'Please check whether the transfer object of Ether is a zero address.'

    def findtransfer_to_zeroaddress(self, contract):
        results = []

        # print(contract.name)
        tainted_value_zero_base = []
        checkvalue_base = []

        for f in contract.all_functions_called:
            if f.function_type == FunctionType.CONSTRUCTOR_VARIABLES or f.function_type == FunctionType.CONSTRUCTOR_CONSTANT_VARIABLES or f.is_constructor:
                ret = []
                for node in f.nodes:
                    for ir in node.irs:
                        if isinstance(ir,Assignment):
                            assig_rvalue = ir.rvalue
                            assig_lvalue = ir._lvalue
                            if assig_lvalue in tainted_value_zero_base:
                                tainted_value_zero_base.remove(assig_lvalue)
                            if isinstance(assig_rvalue,Constant) and assig_rvalue.value == 0:
                                tainted_value_zero_base.append(assig_lvalue)
                            elif assig_rvalue in tainted_value_zero_base:
                                tainted_value_zero_base.append(assig_lvalue)
                            if assig_lvalue in checkvalue_base:
                                checkvalue_base.remove(assig_lvalue)
                            if assig_rvalue in checkvalue_base:
                                checkvalue_base.append(assig_lvalue)
                        elif isinstance(ir, TypeConversion):
                            variable_read = ir.variable
                            # print(ir.type)
                            if ir.lvalue in tainted_value_zero_base:
                                tainted_value_zero_base.remove(ir.lvalue)
                            if variable_read in tainted_value_zero_base:
                                tainted_value_zero_base.append(ir.lvalue)
                            if ir.type == ElementaryType('address') and isinstance(variable_read,Constant) and variable_read.value == 0:
                                tainted_value_zero_base.append(ir.lvalue)
                            if ir.lvalue in checkvalue_base:
                                checkvalue_base.remove(ir.lvalue)
                            if variable_read in checkvalue_base:
                                checkvalue_base.append(ir.lvalue)
                        elif isinstance(ir, Unpack):
                            unpack_lvalue = ir._lvalue
                            if unpack_lvalue in tainted_value_zero_base:
                                tainted_value_zero_base.remove(unpack_lvalue)
                            if unpack_lvalue in checkvalue_base:
                                checkvalue_base.remove(unpack_lvalue)
                        elif isinstance(ir, Binary) and BinaryType.return_bool(ir.type):
                            if any((isinstance(v,Constant) and v.value == 0) or (v in tainted_value_zero_base) for v in ir.read):
                                checkvalue_base.extend(ir.read)
                        elif isinstance(ir, (Send,Transfer)):
                            destination = ir.destination
                            if destination in tainted_value_zero_base and destination not in checkvalue_base:
                                ret.append(node)
                        elif isinstance(ir, Call) and ir.can_send_eth() and hasattr(ir, 'destination'):
                            destination = ir.destination
                            if destination in tainted_value_zero_base and destination not in checkvalue_base:
                                ret.append(node)
                if ret:
                    results.append((f,ret))

        for f in contract.all_functions_called:
            if f.function_type == FunctionType.CONSTRUCTOR_VARIABLES or f.function_type == FunctionType.CONSTRUCTOR_CONSTANT_VARIABLES or f.is_constructor:
                continue
            ret = []
            tainted_value_zero = []
            checkvalue = []
            for v in tainted_value_zero_base:
                tainted_value_zero.append(v)
            for v in checkvalue_base:
                checkvalue.append(v)
            # node_val = None
            # inloop = False
            # print(f.name)
            
            for node in f.nodes:
                # print(node)
                # print(node.type)
                for ir in node.irs:
                    # print(ir)
                    # print(type(ir))
                    if isinstance(ir,Assignment):
                        assig_rvalue = ir.rvalue
                        assig_lvalue = ir._lvalue
                        if assig_lvalue in tainted_value_zero:
                            tainted_value_zero.remove(assig_lvalue)
                        if isinstance(assig_rvalue,Constant) and assig_rvalue.value == 0:
                            tainted_value_zero.append(assig_lvalue)
                        elif assig_rvalue in tainted_value_zero:
                            tainted_value_zero.append(assig_lvalue)
                        if assig_lvalue in checkvalue:
                            checkvalue.remove(assig_lvalue)
                        if assig_rvalue in checkvalue:
                            checkvalue.append(assig_lvalue)
                    elif isinstance(ir, TypeConversion):
                        variable_read = ir.variable
                        # print(ir.type)
                        if ir.lvalue in tainted_value_zero:
                            tainted_value_zero.remove(ir.lvalue)
                        if variable_read in tainted_value_zero:
                            tainted_value_zero.append(ir.lvalue)
                        if ir.type == ElementaryType('address') and isinstance(variable_read,Constant) and variable_read.value == 0:
                            tainted_value_zero.append(ir.lvalue)
                        if ir.lvalue in checkvalue:
                            checkvalue.remove(ir.lvalue)
                        if variable_read in checkvalue:
                            checkvalue.append(ir.lvalue)
                    elif isinstance(ir, Unpack):
                        unpack_lvalue = ir._lvalue
                        if unpack_lvalue in tainted_value_zero:
                            tainted_value_zero.remove(unpack_lvalue)
                        if unpack_lvalue in checkvalue:
                            checkvalue.remove(unpack_lvalue)
                    elif isinstance(ir, Binary) and BinaryType.return_bool(ir.type):
                        if any((isinstance(v,Constant) and v.value == 0) or (v in tainted_value_zero) for v in ir.read):
                            checkvalue.extend(ir.read)
                    elif isinstance(ir, (Send,Transfer)):
                        destination = ir.destination
                        if destination in tainted_value_zero and destination not in checkvalue:
                            ret.append(node)
                    elif isinstance(ir, Call) and ir.can_send_eth() and hasattr(ir, 'destination'):
                        destination = ir.destination
                        if destination in tainted_value_zero and destination not in checkvalue:
                            ret.append(node)
            if ret:
                results.append((f,ret))   
        return results

    def _detect(self):
        results = []
        # print("**************")
        for contract in self.smartfast.contracts:
            transfer_to_zeroaddress = self.findtransfer_to_zeroaddress(contract)
            for (func, nodes) in transfer_to_zeroaddress:

                info = [func, " transfers money to zero address\n"]
                info += ['\tDangerous transfers:\n']
                for node in nodes:
                    info += ['\t- ', node, '\n']

                res = self.generate_result(info)

                results.append(res)
        # print("**************")
        return results