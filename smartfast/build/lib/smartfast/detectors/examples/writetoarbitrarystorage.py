from smartfast.detectors.abstract_detector import AbstractDetector, DetectorClassification
from smartfast.core.cfg.node import NodeType
from smartfast.smartir.operations import (Assignment,Unpack,Binary,Condition,Index)
from smartfast.core.variables.state_variable import StateVariable


class WritetoArbitraryStorage(AbstractDetector):
    """
    Detect function named backdoor
    """

    ARGUMENT = 'writeto-arbitrarystorage'  # smartfast will launch the detector with smartfast.py --mydetector
    HELP = 'Write to Arbitrary Storage Location'
    IMPACT = DetectorClassification.MEDIUM
    CONFIDENCE = DetectorClassification.PROBABLY

    WIKI = 'https://github.com/trailofbits/smartfast/wiki/WritetoArbitraryStorage'
    WIKI_TITLE = 'WritetoArbitraryStorage'
    WIKI_DESCRIPTION = 'Arbitrary input to storage variables can cause key fields to be rewritten.'
    WIKI_EXPLOIT_SCENARIO = '''
```solidity
contract Map {
    address public owner;
    uint256[] map;
    function set(uint256 key, uint256 value) public {
        if (map.length <= key) {
            map.length = key + 1;
        }
        map[key] = value;
    }
}
```'''
    WIKI_RECOMMENDATION = 'Strictly judge the location of storage variables.'

    def findwritetoarbitrarystorage(self, contract):
        results = []

        # print(contract.name)
        for f in contract.functions_and_modifiers_declared:
            # print(f.name)
            if not f.is_implemented or f.is_protected():
                continue
            functionparameters = f.parameters
            # print([v.name for v in f.parameters])
            ret = []
            # node_val = None
            # inloop = False
            checkvalue = []
            for node in f.nodes:
                # print(node)
                # print(node.type)
                if set(['assert(bool)','require(bool)']).intersection([v.name for v in node.solidity_calls]):
                    checkvalue.extend(node.variables_read)
                indexvalue = []
                for ir in node.irs:
                    # print(ir)
                    # print(type(ir))
                    if isinstance(ir,Condition):
                        checkvalue.extend(node.variables_read)
                    elif isinstance(ir,Index):
                        if isinstance(ir.variable_left,StateVariable) and ir.variable_right not in checkvalue and ir.variable_right in functionparameters:
                            indexvalue.append(ir._lvalue)
                    elif isinstance(ir, Assignment):
                        if ir._lvalue in functionparameters:
                            functionparameters.remove(ir._lvalue)
                        if ir.rvalue in functionparameters:
                            functionparameters.append(ir._lvalue)
                        if ir._lvalue in indexvalue:
                            ret.append(node)
                    elif isinstance(ir, Unpack):
                        if ir._lvalue in functionparameters:
                            functionparameters.remove(ir._lvalue)
                    # print("indexvalue")
                    # print(indexvalue)

            if ret:
                results.append((f,ret))   
                # for ir in node.irs:
                #     print(ir)
                #     print(type(ir))
        return results

    def _detect(self):
        results = []
        # print("-------------------------------------")
        for contract in self.smartfast.contracts:
            writetoarbitrarystorage = self.findwritetoarbitrarystorage(contract)
            for (func, nodes) in writetoarbitrarystorage:

                info = [func, " can write the state variable array at will\n"]
                info += ['\tDangerous write operations:\n']
                for node in nodes:
                    info += ['\t- ', node, '\n']

                res = self.generate_result(info)

                results.append(res)
        # print("-------------------------------------")
        return results