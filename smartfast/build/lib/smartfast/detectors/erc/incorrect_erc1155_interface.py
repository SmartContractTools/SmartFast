"""
Detect incorrect erc1155 interface.
"""
from smartfast.detectors.abstract_detector import AbstractDetector, DetectorClassification


class IncorrectERC1155InterfaceDetection(AbstractDetector):
    """
    Incorrect ERC1155 Interface
    """

    ARGUMENT = 'erc1155-interface'
    HELP = 'Incorrect ERC1155 interfaces'
    IMPACT = DetectorClassification.MEDIUM
    CONFIDENCE = DetectorClassification.EXACTLY

    WIKI = 'https://github.com/SmartContractTools/SmartFast/wiki/Detector-Documentation#incorrect-erc1155-interface'

    WIKI_TITLE = 'Incorrect erc1155 interface'
    WIKI_DESCRIPTION = 'Incorrect return values for `ERC1155` functions. A contract compiled with solidity > 0.4.22 interacting with these functions will fail to execute them, as the return value is missing.'
    WIKI_EXPLOIT_SCENARIO = '''
```solidity
contract Token{
    function balanceOf(address _owner, uint256 _id) external view returns (bool);
    //...
}
```
`Token.balanceOf` does not return an uint256 like `ERC1155` expects. Bob deploys the token. Alice creates a contract that interacts with it but assumes a correct `ERC1155` interface implementation. Alice's contract is unable to interact with Bob's contract.'''

    WIKI_RECOMMENDATION = 'Set the appropriate return values and vtypes for the defined `ERC1155` functions.'

    @staticmethod
    def incorrect_erc1155_interface(signature):
        (name, parameters, returnVars) = signature

        # ERC1155
        if name == 'safeTransferFrom' and parameters == ["address","address","uint256","uint256","bytes"] and returnVars != []:
            return True
        if name == 'safeBatchTransferFrom' and parameters == ["address","address","uint256[]","uint256[]","bytes"] and returnVars != []:
            return True
        if name == 'balanceOf' and parameters == ["address","uint256"] and returnVars != ['uint256']:
            return True
        if name == 'balanceOfBatch' and parameters == ["address[]", "uint256[]"] and returnVars != ['uint256[]']:
            return True
        if name == 'setApprovalForAll' and parameters == ["address", "bool"] and returnVars != []:
            return True
        if name == 'isApprovedForAll' and parameters == ["address", "address"] and returnVars != ['bool']:
            return True
        
        return False

    @staticmethod
    def detect_incorrect_erc1155_interface(contract):
        """ Detect incorrect ERC1155 interface

        Returns:
            list(str) : list of incorrect function signatures
        """

        # Verify this is an ERC1155 contract.
        if not contract.is_possible_erc1155():
            return []

        funcs = contract.functions
        functions = [f for f in funcs if IncorrectERC1155InterfaceDetection.incorrect_erc1155_interface(f.signature)]
        return functions

    def _detect(self):
        """ Detect incorrect erc1155 interface

        Returns:
            dict: [contract name] = set(str)  events
        """
        results = []
        for c in self.smartfast.contracts_derived:
            functions = IncorrectERC1155InterfaceDetection.detect_incorrect_erc1155_interface(c)
            if functions:
                for function in functions:
                    info = [c, " has incorrect ERC1155 function interface:", function, "\n"]
                    res = self.generate_result(info)

                    results.append(res)

        return results
