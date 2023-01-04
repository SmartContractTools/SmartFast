"""
Detect incorrect erc1190 interface.
"""
from smartfast.detectors.abstract_detector import AbstractDetector, DetectorClassification


class IncorrectERC1190InterfaceDetection(AbstractDetector):
    """
    Incorrect ERC1190 Interface
    """

    ARGUMENT = 'erc1190-interface'
    HELP = 'Incorrect ERC1190 interfaces'
    IMPACT = DetectorClassification.MEDIUM
    CONFIDENCE = DetectorClassification.EXACTLY

    WIKI = 'https://github.com/SmartContractTools/SmartFast/wiki/Detector-Documentation#incorrect-erc1190-interface'

    WIKI_TITLE = 'Incorrect erc1190 interface'
    WIKI_DESCRIPTION = 'Incorrect return values for `ERC1190` functions. A contract compiled with solidity > 0.4.22 interacting with these functions will fail to execute them, as the return value is missing.'
    WIKI_EXPLOIT_SCENARIO = '''
```solidity
contract Token{
    function approve(address[] owners, uint royaltyForOwnershipTransfer, uint royaltyForRental) returns bool;
    //...
}
```
`Token.approve` does not return an uint256 like `ERC1190` expects. Bob deploys the token. Alice creates a contract that interacts with it but assumes a correct `ERC1190` interface implementation. Alice's contract is unable to interact with Bob's contract.'''

    WIKI_RECOMMENDATION = 'Set the appropriate return values and vtypes for the defined `ERC1190` functions.'

    @staticmethod
    def incorrect_erc1190_interface(signature):
        (name, parameters, returnVars) = signature

        # ERC1190
        if name == 'approve' and parameters == ["address[]","uint256","uint256"] and returnVars != ['uint256']:
            return True
        if name == 'transferCreativeLicense' and parameters == ["address[]","address[]","uint256"] and returnVars != []:
            return True
        if name == 'transferOwnershipLicense' and parameters == ["address[]","address[]","address[]","uint256"] and returnVars != []:
            return True
        if name == 'rentAsset' and parameters == ["address[]", "address[]", "address[]", "uint256"] and returnVars != []:
            return True

        return False

    @staticmethod
    def detect_incorrect_erc1190_interface(contract):
        """ Detect incorrect ERC1190 interface

        Returns:
            list(str) : list of incorrect function signatures
        """

        # Verify this is an ERC1190 contract.
        if not contract.is_possible_erc1190():
            return []

        funcs = contract.functions
        functions = [f for f in funcs if IncorrectERC1190InterfaceDetection.incorrect_erc1190_interface(f.signature)]
        return functions

    def _detect(self):
        """ Detect incorrect erc1190 interface

        Returns:
            dict: [contract name] = set(str)  events
        """
        results = []
        for c in self.smartfast.contracts_derived:
            functions = IncorrectERC1190InterfaceDetection.detect_incorrect_erc1190_interface(c)
            if functions:
                for function in functions:
                    info = [c, " has incorrect ERC1190 function interface:", function, "\n"]
                    res = self.generate_result(info)

                    results.append(res)

        return results
