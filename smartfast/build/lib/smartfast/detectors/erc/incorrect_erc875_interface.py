"""
Detect incorrect erc875 interface.
"""
from smartfast.detectors.abstract_detector import AbstractDetector, DetectorClassification


class IncorrectERC875InterfaceDetection(AbstractDetector):
    """
    Incorrect ERC875 Interface
    """

    ARGUMENT = 'erc875-interface'
    HELP = 'Incorrect ERC875 interfaces'
    IMPACT = DetectorClassification.MEDIUM
    CONFIDENCE = DetectorClassification.EXACTLY

    WIKI = 'https://github.com/SmartContractTools/SmartFast/wiki/Detector-Documentation#incorrect-erc875-interface'

    WIKI_TITLE = 'Incorrect erc875 interface'
    WIKI_DESCRIPTION = 'Incorrect return values for `ERC875` functions. A contract compiled with solidity > 0.4.22 interacting with these functions will fail to execute them, as the return value is missing.'
    WIKI_EXPLOIT_SCENARIO = '''
```solidity
contract Token{
    function balanceOf(address _owner) public view returns (string _balances);
    //...
}
```
`Token.balanceOf` does not return an uint256[] like `ERC875` expects. Bob deploys the token. Alice creates a contract that interacts with it but assumes a correct `ERC875` interface implementation. Alice's contract is unable to interact with Bob's contract.'''

    WIKI_RECOMMENDATION = 'Set the appropriate return values and vtypes for the defined `ERC875` functions.'

    @staticmethod
    def incorrect_erc875_interface(signature):
        (name, parameters, returnVars) = signature

        # ERC875
        if name == 'name' and parameters == [] and returnVars != ['string']:
            return True
        if name == 'symbol' and parameters == [] and returnVars != ['string']:
            return True
        if name == 'balanceOf' and parameters == ['address'] and returnVars != ['uint256[]']:
            return True
        if name == 'transferFrom' and parameters == ["address", "address", "uint256[]"] and returnVars != []:
            return True
        if name == 'transfer' and parameters == ["address", "uint256[]"] and returnVars != []:
            return True
        if name == 'totalSupply' and parameters == [] and returnVars != ['uint256']:
            return True
        if name == 'trade' and parameters == ["uint256","uint256[]","uint8","bytes32","bytes32"] and returnVars != []:
            return True
        if name == 'ownerOf' and parameters == ["uint256"] and returnVars != ['address']:
            return True

        return False

    @staticmethod
    def detect_incorrect_erc875_interface(contract):
        """ Detect incorrect ERC875 interface

        Returns:
            list(str) : list of incorrect function signatures
        """

        # Verify this is an ERC875 contract.
        if not contract.is_possible_erc875():
            return []

        funcs = contract.functions
        functions = [f for f in funcs if IncorrectERC875InterfaceDetection.incorrect_erc875_interface(f.signature)]
        return functions

    def _detect(self):
        """ Detect incorrect erc875 interface

        Returns:
            dict: [contract name] = set(str)  events
        """
        results = []
        for c in self.smartfast.contracts_derived:
            functions = IncorrectERC875InterfaceDetection.detect_incorrect_erc875_interface(c)
            if functions:
                for function in functions:
                    info = [c, " has incorrect ERC875 function interface:", function, "\n"]
                    res = self.generate_result(info)

                    results.append(res)

        return results
