from smartfast.detectors.abstract_detector import AbstractDetector, DetectorClassification
from smartfast.core.cfg.node import NodeType
from smartfast.smartir.operations import (Assignment,Unpack,Binary,SolidityCall)
from smartfast.core.solidity_types import ArrayType
from smartfast.core.declarations import SolidityFunction


class MulVarlenArguments(AbstractDetector):
    """
    Detect function named backdoor
    """

    ARGUMENT = 'mul-var-len-arguments'  # smartfast will launch the detector with smartfast.py --mydetector
    HELP = 'Hash Collisions With Multiple Variable Length Arguments'
    IMPACT = DetectorClassification.MEDIUM
    CONFIDENCE = DetectorClassification.PROBABLY


    WIKI = 'https://github.com/trailofbits/smartfast/wiki/MulVarlenArguments'
    WIKI_TITLE = 'MulVarlenArguments'
    WIKI_DESCRIPTION = 'Hash Collisions With Multiple Variable Length Arguments.(abi.encodePacked())'
    WIKI_EXPLOIT_SCENARIO = '''
```solidity
contract Mulvarlenarguments {
    function addUsers(
        address[] calldata admins,
        address[] calldata regularUsers,
        bytes calldata signature
    )
        external
    {       
        bytes32 hash = keccak256(abi.encodePacked(admins, regularUsers));
        address signer = hash.toEthSignedMessageHash().recover(signature);
    }
}
```'''
    WIKI_RECOMMENDATION = 'The parameters of abi.encodePacked() should be as long as possible.'

    def findmulvarlen_arguments(self, contract):
        results = []

        # print(contract.name)
        for f in contract.functions_and_modifiers_declared:
            if not f.is_implemented or f.is_protected():
                continue
            ret = []
            # print(f.name)
            # node_val = None
            # inloop = False
            for node in f.nodes:
                # print(node)
                # print(node.type)
                for ir in node.irs:
                    # print(ir)
                    # print(type(ir))
                    if isinstance(ir,SolidityCall) and ir.function == SolidityFunction('abi.encodePacked()'):
                        # print("solodity:")
                        # print(ir.read)
                        # print([v.type for v in ir.read])
                        flag = False
                        for v in ir.read:
                            # print(flag)
                            if isinstance(v.type,ArrayType) and v.type.length == None:
                                if flag:                        
                                    ret.append(node)
                                    break
                                else:
                                    flag = True
                            else:
                                flag = False
                        # print(ir.function)
                        # print(ir.nbr_arguments)
                        # print(ir.type_call)
                        # print(ir.lvalue)                   
            if ret:
                results.append((f,ret))   
        return results

    def _detect(self):
        results = []
        # print("-------------------------------------")
        for contract in self.smartfast.contracts:
            mulvarlen_arguments = self.findmulvarlen_arguments(contract)
            for (func, nodes) in mulvarlen_arguments:

                info = [func, " has multiple variable length parameters hash collision\n"]
                info += ['\tPossible hash conflict statements:\n']
                for node in nodes:
                    info += ['\t- ', node, '\n']

                res = self.generate_result(info)

                results.append(res)
        # print("-------------------------------------")
        return results