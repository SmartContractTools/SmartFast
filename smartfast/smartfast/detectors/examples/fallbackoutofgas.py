from smartfast.detectors.abstract_detector import AbstractDetector, DetectorClassification
from smartfast.core.cfg.node import NodeType
from smartfast.smartir.operations import (Assignment,Unpack,Binary)


class FallbackOutofGas(AbstractDetector):
    """
    Detect function named backdoor
    """

    ARGUMENT = 'fllback-outofgas'  # smartfast will launch the detector with smartfast.py --mydetector
    HELP = 'The fallback function is too complicated'
    IMPACT = DetectorClassification.LOW
    CONFIDENCE = DetectorClassification.PROBABLY


    WIKI = 'https://github.com/trailofbits/smartfast/wiki/FallbackOutofGas'
    WIKI_TITLE = 'FallbackOutofGas'
    WIKI_DESCRIPTION = 'The fallback function completed too many operations, exceeding 2300 gas.'
    WIKI_EXPLOIT_SCENARIO = '''
```solidity
contract C {
    function f(uint a, uint b) public{
    uint a = 0;
    do {    
            continue;
            a++;
    } while(a<10);
    }
}
```'''
    WIKI_RECOMMENDATION = 'Please abbreviate the fallback function.'

    fallback_nodes_values_num_max = 10

    def findfallback_outofgas(self, contract):
        results = []

        # print(contract.name)
        for f in contract.all_functions_called:
            # print(f.name)
            if f.is_fallback:
                node_value = 0
                for node in f.nodes:
                    # print(node)
                    node_value = node_value + 1
                if node_value >= 10:
                    results.append(f)
                # print("zonggong:")
                # print(node_value)
        return results

    def _detect(self):
        results = []
        # print("-------------------------------------")
        for contract in self.smartfast.contracts:
            fallback_outofgas = self.findfallback_outofgas(contract)
            if fallback_outofgas:
                info = ["The fallback function ", fallback_outofgas[0], " of contract ", contract," is too complicated\n"]

                res = self.generate_result(info)

                results.append(res)
        # print("-------------------------------------")

        return results