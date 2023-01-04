"""
Module detecting usage of low level calls
"""

from smartfast.detectors.abstract_detector import AbstractDetector, DetectorClassification
from smartfast.smartir.operations import LowLevelCall,SolidityCall,Send


class InvokeLowLevelCalls(AbstractDetector):
    """
    Detect usage of low level calls
    """

    ARGUMENT = 'low-level-calls'
    HELP = 'Low level calls'
    IMPACT = DetectorClassification.INFORMATIONAL
    CONFIDENCE = DetectorClassification.EXACTLY

    WIKI = 'https://github.com/SmartContractTools/SmartFast/wiki/Detector-Documentation#low-level-calls'

    WIKI_TITLE = 'Low-level calls'
    WIKI_DESCRIPTION = 'The use of low-level calls is error-prone. Low-level calls do not check for [code existence](https://solidity.readthedocs.io/en/v0.4.25/control-structures.html#error-handling-assert-require-revert-and-exceptions) or call success.'
    WIKI_RECOMMENDATION = 'Avoid low-level calls. Check the call success. If the call is meant for a contract, check for code existence.'

    @staticmethod
    def _contains_low_level_calls(node):
        """
             Check if the node contains Low Level Calls
        Returns:
            (bool)
        """
        # print(node)
        # print(node.type)
        # for ir in node.irs:
        #     print(ir)
        #     print(type(ir))
        #     if isinstance(ir, SolidityCall):
        #         print(ir.function)
        #         if ir.function.full_name in ["suicide(address)", "selfdestruct(address)"]:
        #             print("****************")
        #     print(any(isinstance(ir, LowLevelCall) or (isinstance(ir, SolidityCall) and ir.function.full_name in ["suicide(address)", "selfdestruct(address)"]) for ir in node.irs))
        return any(isinstance(ir, LowLevelCall) or isinstance(ir, Send) or (isinstance(ir, SolidityCall) and ir.function.full_name in ["suicide(address)", "selfdestruct(address)"]) for ir in node.irs)

    def detect_low_level_calls(self, contract):
        ret = []
        for f in [f for f in contract.functions + contract.modifiers if contract == f.contract_declarer]:
            # print(f.full_name)
            nodes = f.nodes
            assembly_nodes = [n for n in nodes if
                              self._contains_low_level_calls(n)]
            # print("------------")
            if assembly_nodes:
                ret.append((f, assembly_nodes))
        return ret

    def _detect(self):
        """ Detect the functions that use low level calls
        """
        results = []
        for c in self.contracts:
            values = self.detect_low_level_calls(c)
            for func, nodes in values:
                info = ["Low level call in ", func, ":\n"]

                for node in nodes:
                    info += ['\t- ', node, '\n']

                res = self.generate_result(info)

                results.append(res)

        return results
