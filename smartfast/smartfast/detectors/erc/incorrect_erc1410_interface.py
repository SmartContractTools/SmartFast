"""
Detect incorrect erc1410 interface.
"""
from smartfast.detectors.abstract_detector import AbstractDetector, DetectorClassification


class IncorrectERC1410InterfaceDetection(AbstractDetector):
    """
    Incorrect ERC1410 Interface
    """

    ARGUMENT = 'erc1410-interface'
    HELP = 'Incorrect ERC1410 interfaces'
    IMPACT = DetectorClassification.MEDIUM
    CONFIDENCE = DetectorClassification.EXACTLY

    WIKI = 'https://github.com/SmartContractTools/SmartFast/wiki/Detector-Documentation#incorrect-erc1410-interface'

    WIKI_TITLE = 'Incorrect erc1410 interface'
    WIKI_DESCRIPTION = 'Incorrect return values for `ERC1410` functions. A contract compiled with solidity > 0.4.22 interacting with these functions will fail to execute them, as the return value is missing.'
    WIKI_EXPLOIT_SCENARIO = '''
```solidity
contract Token{
    function isOperator(address _operator, address _tokenHolder) external view returns (uint256);
    //...
}
```
`Token.isOperator` does not return an bool like `ERC1410` expects. Bob deploys the token. Alice creates a contract that interacts with it but assumes a correct `ERC1410` interface implementation. Alice's contract is unable to interact with Bob's contract.'''

    WIKI_RECOMMENDATION = 'Set the appropriate return values and vtypes for the defined `ERC1410` functions.'

    @staticmethod
    def incorrect_erc1410_interface(signature):
        (name, parameters, returnVars) = signature
        # print(name)
        # print(parameters)
        # print(returnVars)
        # ERC1410
        if name == 'balanceOf' and parameters == ['address'] and returnVars != ['uint256']:
            return True
        if name == 'balanceOfByPartition' and parameters == ["bytes32","address"] and returnVars != ['uint256']:
            return True
        if name == 'partitionsOf' and parameters == ["address"] and returnVars != ['bytes32[]']:
            return True
        if name == 'totalSupply' and parameters == [] and returnVars != ['uint256']:
            return True
        if name == 'transferByPartition' and parameters == ["bytes32", "address", "uint256", "bytes"] and returnVars != ['bytes32']:
            return True
        if name == 'operatorTransferByPartition' and parameters == ["bytes32", "address", "address", "uint256", "bytes", "bytes"] and returnVars != ['bytes32']:
            return True
        if name == 'canTransferByPartition' and parameters == ["address", "address", "bytes32", "uint256", "bytes"] and returnVars != ["bytes1", "bytes32", "bytes32"]:
            return True
        if name == 'isOperator' and parameters == ["address", "address"] and returnVars != ['bool']:
            return True
        if name == 'isOperatorForPartition' and parameters == ["bytes32", "address", "address"] and returnVars != ['bool']:
            return True
        if name == 'authorizeOperator' and parameters == ["address"] and returnVars != []:
            return True
        if name == 'revokeOperator' and parameters == ["address"] and returnVars != []:
            return True
        if name == 'authorizeOperatorByPartition' and parameters == ["bytes32", "address"] and returnVars != []:
            return True
        if name == 'revokeOperatorByPartition' and parameters == ["bytes32", "address"] and returnVars != []:
            return True
        if name == 'issueByPartition' and parameters == ["bytes32", "address", "uint256", "bytes"] and returnVars != []:
            return True
        if name == 'redeemByPartition' and parameters == ["bytes32", "uint256", "bytes"] and returnVars != []:
            return True
        if name == 'operatorRedeemByPartition' and parameters == ["bytes32", "address", "uint256", "bytes"] and returnVars != []:
            return True

        return False

    @staticmethod
    def detect_incorrect_erc1410_interface(contract):
        """ Detect incorrect ERC1410 interface

        Returns:
            list(str) : list of incorrect function signatures
        """

        # Verify this is an ERC1410 contract.
        if not contract.is_possible_erc1410():
            return []

        funcs = contract.functions
        functions = [f for f in funcs if IncorrectERC1410InterfaceDetection.incorrect_erc1410_interface(f.signature)]
        return functions

    def _detect(self):
        """ Detect incorrect erc1410 interface

        Returns:
            dict: [contract name] = set(str)  events
        """
        results = []
        for c in self.smartfast.contracts_derived:
            functions = IncorrectERC1410InterfaceDetection.detect_incorrect_erc1410_interface(c)
            if functions:
                for function in functions:
                    info = [c, " has incorrect ERC1410 function interface:", function, "\n"]
                    res = self.generate_result(info)

                    results.append(res)

        return results
