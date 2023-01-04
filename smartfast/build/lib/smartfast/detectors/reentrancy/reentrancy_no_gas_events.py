""""
    Re-entrancy detection

    Based on heuristics, it may lead to FP and FN
    Iterate over all the nodes of the graph until reaching a fixpoint
"""
from collections import namedtuple, defaultdict

from smartfast.detectors.abstract_detector import DetectorClassification
from .reentrancy import Reentrancy, to_hashable
from smartfast.smartir.operations import Call,Send, Transfer

FindingKey = namedtuple('FindingKey', ['function', 'calls', 'send_eth'])
FindingValue = namedtuple('FindingValue', ['variable', 'node', 'nodes'])


class ReentrancyNoGasEvent(Reentrancy):
    KEY = 'REENTRANCY_NO_GAS'
    ARGUMENT = 'reentrancy-limited-events'
    HELP = 'Reentrancy vulnerabilities leading to out-of-order Events'
    IMPACT = DetectorClassification.INFORMATIONAL
    CONFIDENCE = DetectorClassification.PROBABLY

    WIKI = 'https://github.com/SmartContractTools/SmartFast/wiki/Detector-Documentation#reentrancy-vulnerabilities-limitedgas-events'

    WIKI_TITLE = 'Reentrancy vulnerabilities'
    WIKI_DESCRIPTION = '''
Detection of the [reentrancy bug](https://github.com/trailofbits/not-so-smart-contracts/tree/master/reentrancy).
Only report reentrancies that are based on `transfer` or `send` leading to out-of-order events.'''
    WIKI_EXPLOIT_SCENARIO = '''
```solidity
    function bug(Called d){
        uint sendeth = 0;
        msg.sender.send(sendeth):
        emit Counter(counter);
    }
```

If `send` re-enters, the `Counter` events will be shown in an incorrect order, which might lead to issues for third parties.'''

    WIKI_RECOMMENDATION = 'Apply the [`check-effects-interactions` pattern](http://solidity.readthedocs.io/en/v0.4.21/security-considerations.html#re-entrancy).'

    STANDARD_JSON = False

    @staticmethod
    def can_callback(ir):
        return isinstance(ir, (Send, Transfer))

    def find_reentrancies(self):
        result = defaultdict(set)
        for contract in self.contracts:
            for f in contract.functions_and_modifiers_declared:
                for node in f.nodes:
                    # print(node)
                    # print(self.KEY in node.context)
                    # print(self.KEY_no_gas in node.context)
                    # dead code
                    if self.KEY not in node.context:
                        continue
                    if node.context[self.KEY].calls:
                    #(self.KEY in node.context and node.context[self.KEY].calls) or (self.KEY_no_gas in node.context and node.context[self.KEY_no_gas].calls and not node.context[self.KEY_no_gas].send_eth):
                        if not any(n != node for n in node.context[self.KEY].calls):
                            continue

                        # calls are ordered
                        finding_key = FindingKey(function=node.function,
                                                 calls=to_hashable(node.context[self.KEY].calls),
                                                 send_eth=to_hashable(node.context[self.KEY].send_eth))
                        finding_vars = set([FindingValue(e,
                                                         e.node,
                                                         tuple(sorted(nodes, key=lambda x: x.node_id)))
                                            for (e, nodes)
                                            in node.context[self.KEY].events.items()])
                        if finding_vars:
                            result[finding_key] |= finding_vars
        return result

    def _detect(self):
        """
        """
        super()._detect()

        reentrancies = self.find_reentrancies()

        results = []

        result_sorted = sorted(list(reentrancies.items()), key=lambda x: x[0][0].name)
        for (func, calls, send_eth), events in result_sorted:
            calls = sorted(list(set(calls)), key=lambda x: x[0].node_id)
            send_eth = sorted(list(set(send_eth)), key=lambda x: x[0].node_id)
            events = sorted(events, key=lambda x: (str(x.variable.name), x.node.node_id))

            info = ['Reentrancy in ', func, ':\n']
            info += ['\tExternal calls:\n']
            for (call_info, calls_list) in calls:
                info += ['\t- ', call_info, '\n']
                for call_list_info in calls_list:
                    if call_list_info != call_info:
                        info += ['\t\t- ', call_list_info, '\n']
            if calls != send_eth and send_eth:
                info += ['\tExternal calls sending eth:\n']
                for (call_info, calls_list) in send_eth:
                    info += ['\t- ', call_info, '\n']
                    for call_list_info in calls_list:
                        if call_list_info != call_info:
                            info += ['\t\t- ', call_list_info, '\n']
            info += ['\tEvent emitted after the call(s):\n']
            for finding_value in events:
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

            #

            # If the calls are not the same ones that send eth, add the eth sending nodes.
            if calls != send_eth:
                for (call_info, calls_list) in send_eth:
                    res.add(call_info, {
                        "underlying_type": "external_calls_sending_eth"
                    })
                    for call_list_info in calls_list:
                        if call_list_info != call_info:
                            res.add(call_list_info, {
                                "underlying_type": "external_calls_sending_eth"
                            })

            for finding_value in events:
                res.add(finding_value.node, {
                    "underlying_type": "event"
                })
                for other_node in finding_value.nodes:
                    if other_node != finding_value.node:
                        res.add(other_node, {
                            "underlying_type": "event"
                        })

            # Append our result
            results.append(res)

        return results
