from smartfast.detectors.abstract_detector import AbstractDetector, DetectorClassification
from smartfast.core.cfg.node import NodeType
from smartfast.smartir.operations import (Assignment,Unpack,Binary)
import difflib


class IncorrectConstructor(AbstractDetector):
    """
    Detect function named backdoor
    """

    ARGUMENT = 'incorrect-constructor'  # smartfast will launch the detector with smartfast.py --mydetector
    HELP = 'Constructor name error'
    IMPACT = DetectorClassification.HIGH
    CONFIDENCE = DetectorClassification.PROBABLY

    WIKI = 'https://github.com/trailofbits/smartfast/wiki/incorrect-constructor'
    WIKI_TITLE = 'IncorrectConstructor'
    WIKI_DESCRIPTION = 'The Constructor has a wrong name and is easily called by others.'
    WIKI_EXPLOIT_SCENARIO = '''
```solidity
contract Incorrectconstructor {
    address owner;
    function Incorrectconstructo() {
        owner = msg.sender;
    }

    modifier ifowner()
    {
        require(msg.sender == owner);
        _;
    }

    function withdrawmoney() ifowner {
        msg.sender.transfer(address(this).balance);
    }
}
```'''
    WIKI_RECOMMENDATION = 'Please check if the constructor is wrong.'

    def findincorrectconstructor(self, contract):
        results = []

        # print(contract.name)
        contract_name = contract.name
        for f in contract.functions_and_modifiers_declared:
            # print(f.name)
            if f.is_fallback:
                continue
            # print()
            if difflib.SequenceMatcher(None, contract_name, f.name).quick_ratio() >= 0.9:
                results.append(f)
 
        return results

    def _detect(self):
        results = []

        for contract in self.smartfast.contracts:
            # print(contract.name)
            if contract.constructors_declared:
                continue
            incorrect_constructor = self.findincorrectconstructor(contract)
            if incorrect_constructor:
                info = [contract, " may have a constructor with the wrong name\n"]
                for func in incorrect_constructor:
                    info += ['\t- ', func, " may be a constructor\n"]
                res = self.generate_result(info)
                results.append(res)

        return results