""""
    Re-entrancy detection

    Based on heuristics, it may lead to FP and FN
    Iterate over all the nodes of the graph until reaching a fixpoint
"""
from collections import namedtuple, defaultdict

from smartfast.core.variables.variable import Variable
from smartfast.detectors.abstract_detector import DetectorClassification
from smartfast.smartir.operations import Send, Transfer, EventCall
from .reentrancy import Reentrancy, to_hashable

FindingKey = namedtuple('FindingKey', ['function', 'calls'])
FindingValue = namedtuple('FindingValue', ['variable', 'node', 'nodes'])


class ReentrancyNoGasNoEth(Reentrancy):
    KEY = 'REENTRANCY_NO_GAS'

    ARGUMENT = 'reentrancy-limited-gas-no-eth'
    HELP = 'Reentrancy vulnerabilities through send and transfer (no eth)'
    IMPACT = DetectorClassification.INFORMATIONAL
    CONFIDENCE = DetectorClassification.PROBABLY

    WIKI = 'https://github.com/SmartContractTools/SmartFast/wiki/Detector-Documentation#reentrancy-vulnerabilities-limitedgas-noeth'

    WIKI_TITLE = 'Reentrancy vulnerabilities'
    WIKI_DESCRIPTION = '''
Detection of the [reentrancy bug](https://github.com/trailofbits/not-so-smart-contracts/tree/master/reentrancy).
Only report worthless reentrancy that is based on `transfer` or `send`.'''
    WIKI_EXPLOIT_SCENARIO = '''
```solidity
    function callme(){
        uint sendeth = 0;
        msg.sender.transfer(sendeth):
        balances[msg.sender] = balances[msg.sender] - sendeth;
    }   
```

`send` and `transfer` do not protect from reentrancies in case of gas price changes.'''

    WIKI_RECOMMENDATION = 'Apply the [`check-effects-interactions` pattern](http://solidity.readthedocs.io/en/v0.4.21/security-considerations.html#re-entrancy).'

    @staticmethod
    def can_callback(ir):
        """
        Same as Reentrancy, but also consider Send and Transfer

        """
        return isinstance(ir, (Send, Transfer))

    STANDARD_JSON = False

    def find_reentrancies(self):
        result = defaultdict(set)
        for contract in self.contracts:
            for f in contract.functions_and_modifiers_declared:
                for node in f.nodes:
                    # print(node)
                    # dead code
                    if self.KEY not in node.context:
                        continue
                    if node.context[self.KEY].calls and not node.context[self.KEY].send_eth:
                        finding_vars = set()
                        for c in node.context[self.KEY].calls:
                            if c == node:
                                continue
                            finding_vars |= set([FindingValue(v,
                                                             node,
                                                             tuple(sorted(nodes, key=lambda x: x.node_id)))
                                                for (v, nodes)
                                                in node.context[self.KEY].written.items()]) 
                        if finding_vars:
                            finding_key = FindingKey(function=node.function,
                                                     calls=to_hashable(node.context[self.KEY].calls))
                            result[finding_key] |= finding_vars
        return result

    def _detect(self):
        """
        """

        super()._detect()
        reentrancies = self.find_reentrancies()

        results = []

        result_sorted = sorted(list(reentrancies.items()), key=lambda x: x[0][0].name)
        for (func, calls), varsWritten in result_sorted:
            calls = sorted(list(set(calls)), key=lambda x: x[0].node_id)
            varsWritten = sorted(varsWritten, key=lambda x: (x.variable.name, x.node.node_id))
            info = ['Reentrancy in ', func, ':\n']

            info += ['\tExternal calls:\n']
            for (call_info, calls_list) in calls:
                info += ['\t- ', call_info, '\n']
                for call_list_info in calls_list:
                    if call_list_info != call_info:
                        info += ['\t\t- ', call_list_info, '\n']
            if varsWritten:
                info += '\tState variables written after the call(s):\n'
                for finding_value in varsWritten:
                    info += ['\t- ', finding_value.node, '\n']
                    for other_node in finding_value.nodes:
                        if other_node != finding_value.node:
                            info += ['\t\t- ', other_node, '\n']

            # Create our JSON result
            res = self.generate_result(info)

            # Add the function with the re-entrancy first
            res.add(func)

            # Add all underlying calls in the function which are potentially problematic.
            for (call_info, calls_list) in calls:
                res.add(call_info, {
                    "underlying_type": "external_calls"
                })
                for call_list_info in calls_list:
                    if call_list_info != call_info:
                        res.add(call_list_info, {
                            "underlying_type": "external_calls_sending_eth"
                        })

            # Add all variables written via nodes which write them.
            for finding_value in varsWritten:
                res.add(finding_value.node, {
                    "underlying_type": "variables_written",
                    "variable_name": finding_value.variable.name
                })
                for other_node in finding_value.nodes:
                    if other_node != finding_value.node:
                        res.add(other_node, {
                            "underlying_type": "variables_written",
                            "variable_name": finding_value.variable.name
                        })

            # Append our result
            results.append(res)

        return results