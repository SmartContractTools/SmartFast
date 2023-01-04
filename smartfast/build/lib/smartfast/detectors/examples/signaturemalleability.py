from smartfast.detectors.abstract_detector import AbstractDetector, DetectorClassification
from smartfast.core.cfg.node import NodeType
from smartfast.smartir.operations import (Assignment,Unpack,Binary,SolidityCall,TypeConversion)
from smartfast.core.declarations.function import Function, FunctionType
from smartfast.core.declarations.solidity_variables import SolidityFunction

class SignatureMalleability(AbstractDetector):
    """
    Detect function named backdoor
    """

    ARGUMENT = 'signature-malleability'  # smartfast will launch the detector with smartfast.py --mydetector
    HELP = 'The signature contains an existing signature'
    IMPACT = DetectorClassification.LOW
    CONFIDENCE = DetectorClassification.POSSIBLY


    WIKI = 'https://github.com/trailofbits/smartfast/wiki/SignatureMalleability'
    WIKI_TITLE = 'SignatureMalleability'
    WIKI_DESCRIPTION = 'The signature contains an existing signature.'
    WIKI_EXPLOIT_SCENARIO = '''
```solidity
function transfer(bytes _signature,address _to,uint256 _value,uint256 _gasPrice,uint256 _nonce) public returns (bool){
    bytes32 txid = keccak256(abi.encodePacked(getTransferHash(_to, _value, _gasPrice, _nonce), _signature)); //bad
    require(!signatureUsed[txid]);

    address from = recoverTransferPreSigned(_signature, _to, _value, _gasPrice, _nonce);

    require(balances[from] > _value);
    balances[from] -= _value;
    balances[_to] += _value;

    signatureUsed[txid] = true;
}
```'''
    WIKI_RECOMMENDATION = 'The signature should not include an existing signature.'

    def findsignaturemalleability(self, contract):
        results = []

        # print(contract.name)
        encodePacked_value_base = []
        for f in contract.all_functions_called:
            if f.function_type == FunctionType.CONSTRUCTOR_VARIABLES or f.function_type == FunctionType.CONSTRUCTOR_CONSTANT_VARIABLES or f.is_constructor:
                ret = []
                for node in f.nodes:
                    for ir in node.irs:
                        if isinstance(ir, SolidityCall):
                            if ir.function ==  SolidityFunction("abi.encodePacked()"):
                                if ir.nbr_arguments >= 2 and 'bytes' in [v.type.name for v in ir.read]:
                                    encodePacked_value_base.append(ir._lvalue)
                            elif ir.function ==  SolidityFunction("keccak256()"):
                                for v in encodePacked_value_base:
                                    if v in ir.read:
                                        ret.append(node)
                                        break
                        elif isinstance(ir,Assignment):
                            assig_rvalue = ir.rvalue
                            assig_lvalue = ir._lvalue
                            if assig_lvalue in encodePacked_value_base:
                                encodePacked_value_base.remove(assig_lvalue)
                            if assig_rvalue in encodePacked_value_base:
                                encodePacked_value_base.append(assig_lvalue)
                        elif isinstance(ir, TypeConversion):
                            variable_read = ir.variable
                            # print(ir.type)
                            if ir.lvalue in encodePacked_value_base:
                                encodePacked_value_base.remove(ir.lvalue)
                            if variable_read in encodePacked_value_base:
                                encodePacked_value_base.append(ir.lvalue)
                        elif isinstance(ir, Unpack):
                            unpack_lvalue = ir._lvalue
                            if unpack_lvalue in encodePacked_value_base:
                                encodePacked_value_base.remove(unpack_lvalue)

        for f in contract.all_functions_called:
            if f.function_type == FunctionType.CONSTRUCTOR_VARIABLES or f.function_type == FunctionType.CONSTRUCTOR_CONSTANT_VARIABLES or f.is_constructor:
                continue
            encodePacked_value = []
            for v in encodePacked_value_base:
                encodePacked_value.append(v)
            ret = []
            # print("*****************")
            # print(f.name)
            # print("*****************")
            for node in f.nodes:
                # print(node)
                # print(node.type)
                for ir in node.irs:
                    # print(ir)
                    # print(type(ir))
                    if isinstance(ir, SolidityCall):
                        if ir.function ==  SolidityFunction("abi.encodePacked()"):
                            if ir.nbr_arguments >= 2 and 'bytes' in [v.type.name for v in ir.read if hasattr(v.type,'name')]:
                                encodePacked_value.append(ir._lvalue)
                        elif ir.function ==  SolidityFunction("keccak256()"):
                            # print([type(v) for v in ir.read])
                            for v in encodePacked_value:
                                if v in ir.read:
                                    ret.append(node)
                                    break
                    elif isinstance(ir,Assignment):
                        assig_rvalue = ir.rvalue
                        assig_lvalue = ir._lvalue
                        if assig_lvalue in encodePacked_value:
                            encodePacked_value.remove(assig_lvalue)
                        if assig_rvalue in encodePacked_value:
                            encodePacked_value.append(assig_lvalue)
                    elif isinstance(ir, TypeConversion):
                        variable_read = ir.variable
                        # print(ir.type)
                        if ir.lvalue in encodePacked_value:
                            encodePacked_value.remove(ir.lvalue)
                        if variable_read in encodePacked_value:
                            encodePacked_value.append(ir.lvalue)
                    elif isinstance(ir, Unpack):
                        unpack_lvalue = ir._lvalue
                        if unpack_lvalue in encodePacked_value:
                            encodePacked_value.remove(unpack_lvalue)

            if ret:
                results.append((f,ret))

        return results

    def _detect(self):
        results = []
        # print("---------------")
        for contract in self.smartfast.contracts:
            signaturemalleability = self.findsignaturemalleability(contract)
            for (func, nodes) in signaturemalleability:

                info = [func, " has the signature malleability\n"]
                info += ['\tDangerous signatures:\n']
                for node in nodes:
                    info += ['\t- ', node, '\n']

                res = self.generate_result(info)

                results.append(res)
        # print("---------------")
        return results