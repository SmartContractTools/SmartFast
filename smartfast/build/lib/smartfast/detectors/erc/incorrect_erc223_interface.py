"""
Detect incorrect erc223 interface.
"""
from smartfast.detectors.abstract_detector import AbstractDetector, DetectorClassification


class IncorrectERC223InterfaceDetection(AbstractDetector):
    """
    Incorrect ERC223 Interface
    """

    ARGUMENT = 'erc223-interface'
    HELP = 'Incorrect ERC223 interfaces'
    IMPACT = DetectorClassification.MEDIUM
    CONFIDENCE = DetectorClassification.EXACTLY

    WIKI = 'https://github.com/SmartContractTools/SmartFast/wiki/Detector-Documentation#incorrect-erc223-interface'

    WIKI_TITLE = 'Incorrect erc223 interface'
    WIKI_DESCRIPTION = 'Incorrect return values for `ERC223` functions. A contract compiled with solidity > 0.4.22 interacting with these functions will fail to execute them, as the return value is missing.'
    WIKI_EXPLOIT_SCENARIO = '''
```solidity
contract Token{
    function name() constant returns (uint _name);
    //...
}
```
`Token.name` does not return an string like `ERC223` expects. Bob deploys the token. Alice creates a contract that interacts with it but assumes a correct `ERC223` interface implementation. Alice's contract is unable to interact with Bob's contract.'''

    WIKI_RECOMMENDATION = 'Set the appropriate return values and vtypes for the defined `ERC223` functions.'

    @staticmethod
    def incorrect_erc223_interface(signature):
        (name, parameters, returnVars) = signature

        # ERC223
        if name == 'name' and parameters == [] and returnVars != ['string']:
            return True
        if name == 'symbol' and parameters == [] and returnVars != ['string']:
            return True
        if name == 'decimals' and parameters == [] and returnVars != ['uint8']:
            return True
        if name == 'totalSupply' and parameters == [] and returnVars != ['uint256']:
            return True
        if name == 'balanceOf' and parameters == ["address"] and returnVars != ['uint256']:
            return True
        if name == 'transfer' and parameters == ["address", "uint256"] and returnVars != ['bool']:
            return True
        if name == 'transfer' and parameters == ["address", "uint256", "bytes"] and returnVars != ['bool']:
            return True
        if name == 'transfer' and parameters == ["address", "uint256", "bytes", "string"] and returnVars != ['bool']:
            return True

        return False

    @staticmethod
    def detect_incorrect_erc223_interface(contract):
        """ Detect incorrect ERC223 interface

        Returns:
            list(str) : list of incorrect function signatures
        """

        # Verify this is an ERC223 contract.
        if not contract.is_possible_erc223():
            return []

        funcs = contract.functions
        functions = [f for f in funcs if IncorrectERC223InterfaceDetection.incorrect_erc223_interface(f.signature)]
        return functions

    def _detect(self):
        """ Detect incorrect erc223 interface

        Returns:
            dict: [contract name] = set(str)  events
        """
        results = []
        for c in self.smartfast.contracts_derived:
            functions = IncorrectERC223InterfaceDetection.detect_incorrect_erc223_interface(c)
            if functions:
                for function in functions:
                    info = [c, " has incorrect ERC223 function interface:", function, "\n"]
                    res = self.generate_result(info)

                    results.append(res)

        return results
