"""
Detect incorrect erc621 interface.
"""
from smartfast.detectors.abstract_detector import AbstractDetector, DetectorClassification


class IncorrectERC621InterfaceDetection(AbstractDetector):
    """
    Incorrect ERC621 Interface
    """

    ARGUMENT = 'erc621-interface'
    HELP = 'Incorrect ERC621 interfaces'
    IMPACT = DetectorClassification.MEDIUM
    CONFIDENCE = DetectorClassification.EXACTLY

    WIKI = 'https://github.com/SmartContractTools/SmartFast/wiki/Detector-Documentation#incorrect-erc621-interface'

    WIKI_TITLE = 'Incorrect erc621 interface'
    WIKI_DESCRIPTION = 'Incorrect return values for `ERC621` functions. A contract compiled with solidity > 0.4.22 interacting with these functions will fail to execute them, as the return value is missing.'
    WIKI_EXPLOIT_SCENARIO = '''
```solidity
contract Token{
    function decreaseSupply(uint value, address from) external;
    //...
}
```
`Token.decreaseSupply` does not return an bool like `ERC621` expects. Bob deploys the token. Alice creates a contract that interacts with it but assumes a correct `ERC621` interface implementation. Alice's contract is unable to interact with Bob's contract.'''

    WIKI_RECOMMENDATION = 'Set the appropriate return values and vtypes for the defined `ERC621` functions.'

    @staticmethod
    def incorrect_erc621_interface(signature):
        (name, parameters, returnVars) = signature

        # ERC621
        if name == 'totalSupply' and parameters == [] and returnVars != ['uint256']:
            return True
        if name == 'balanceOf' and parameters == ["address"] and returnVars != ['uint256']:
            return True
        if name == 'transfer' and parameters == ["address", "uint256"] and returnVars != ['bool']:
            return True
        if name == 'transferFrom' and parameters == ["address", "address", "uint256"] and returnVars != ['bool']:
            return True
        if name == 'approve' and parameters == ["address", "uint256"] and returnVars != ['bool']:
            return True
        if name == 'allowance' and parameters == ["address", "address"] and returnVars != ['uint256']:
            return True
        if name == 'increaseSupply' and parameters == ["uint256", "address"] and returnVars != ['bool']:
            return True
        if name == 'safeAdd' and parameters == ["uint256", "uint256"] and returnVars != ['uint256']:
            return True
        if name == 'decreaseSupply' and parameters == ["uint256", "address"] and returnVars != ['bool']:
            return True
        if name == 'safeSub' and parameters == ["uint256", "uint256"] and returnVars != ['uint256']:
            return True

        return False

    @staticmethod
    def detect_incorrect_erc621_interface(contract):
        """ Detect incorrect ERC621 interface

        Returns:
            list(str) : list of incorrect function signatures
        """

        # Verify this is an ERC621 contract.
        if not contract.is_possible_erc621() or not contract.is_possible_erc20():
            return []

        funcs = contract.functions
        functions = [f for f in funcs if IncorrectERC621InterfaceDetection.incorrect_erc621_interface(f.signature)]
        return functions

    def _detect(self):
        """ Detect incorrect erc621 interface

        Returns:
            dict: [contract name] = set(str)  events
        """
        results = []
        for c in self.smartfast.contracts_derived:
            functions = IncorrectERC621InterfaceDetection.detect_incorrect_erc621_interface(c)
            if functions:
                for function in functions:
                    info = [c, " has incorrect ERC621 function interface:", function, "\n"]
                    res = self.generate_result(info)

                    results.append(res)

        return results
