"""
Detect incorrect erc777 interface.
"""
from smartfast.detectors.abstract_detector import AbstractDetector, DetectorClassification


class IncorrectERC777InterfaceDetection(AbstractDetector):
    """
    Incorrect ERC777 Interface
    """

    ARGUMENT = 'erc777-interface'
    HELP = 'Incorrect ERC777 interfaces'
    IMPACT = DetectorClassification.MEDIUM
    CONFIDENCE = DetectorClassification.EXACTLY

    WIKI = 'https://github.com/SmartContractTools/SmartFast/wiki/Detector-Documentation#incorrect-erc777-interface'

    WIKI_TITLE = 'Incorrect erc777 interface'
    WIKI_DESCRIPTION = 'Incorrect return values for `ERC777` functions. A contract compiled with solidity > 0.4.22 interacting with these functions will fail to execute them, as the return value is missing.'
    WIKI_EXPLOIT_SCENARIO = '''
```solidity
contract Token{
    function defaultOperators() public view returns (address);
    //...
}
```
`Token.defaultOperators` does not return an address[] like `ERC777` expects. Bob deploys the token. Alice creates a contract that interacts with it but assumes a correct `ERC777` interface implementation. Alice's contract is unable to interact with Bob's contract.'''

    WIKI_RECOMMENDATION = 'Set the appropriate return values and vtypes for the defined `ERC777` functions.'

    @staticmethod
    def incorrect_erc777_interface(signature):
        (name, parameters, returnVars) = signature

        # ERC777
        if name == 'name' and parameters == [] and returnVars != ['string']:
            return True
        if name == 'symbol' and parameters == [] and returnVars != ['string']:
            return True
        if name == 'totalSupply' and parameters == [] and returnVars != ['uint256']:
            return True
        if name == 'balanceOf' and parameters == ['address'] and returnVars != ['uint256']:
            return True
        if name == 'granularity' and parameters == [] and returnVars != ['uint256']:
            return True
        if name == 'defaultOperators' and parameters == [] and returnVars != ['address[]']:
            return True
        if name == 'isOperatorFor' and parameters == ['address', 'address'] and returnVars != ['bool']:
            return True
        if name == 'authorizeOperator' and parameters == ['address'] and returnVars != []:
            return True
        if name == 'revokeOperator' and parameters == ['address'] and returnVars != []:
            return True
        if name == 'send' and parameters == ["address", "uint256", "bytes"] and returnVars != []:
            return True
        if name == 'operatorSend' and parameters == ["address", "address", "uint256", "bytes", "bytes"] and returnVars != []:
            return True
        if name == 'burn' and parameters == ["uint256", "bytes"] and returnVars != []:
            return True
        if name == 'operatorBurn' and parameters == ["address", "uint256", "bytes", "bytes"] and returnVars != []:
            return True

        return False

    @staticmethod
    def detect_incorrect_erc777_interface(contract):
        """ Detect incorrect ERC777 interface

        Returns:
            list(str) : list of incorrect function signatures
        """

        # Verify this is an ERC777 contract.
        if not contract.is_possible_erc777():
            return []

        funcs = contract.functions
        functions = [f for f in funcs if IncorrectERC777InterfaceDetection.incorrect_erc777_interface(f.signature)]
        return functions

    def _detect(self):
        """ Detect incorrect erc777 interface

        Returns:
            dict: [contract name] = set(str)  events
        """
        results = []
        for c in self.smartfast.contracts_derived:
            functions = IncorrectERC777InterfaceDetection.detect_incorrect_erc777_interface(c)
            if functions:
                for function in functions:
                    info = [c, " has incorrect ERC777 function interface:", function, "\n"]
                    res = self.generate_result(info)

                    results.append(res)

        return results
