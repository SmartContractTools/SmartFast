"""
Module detecting deprecated standards.
"""

from smartfast.detectors.abstract_detector import AbstractDetector, DetectorClassification
from smartfast.visitors.expression.export_values import ExportValues
from smartfast.core.declarations.solidity_variables import SolidityVariableComposed, SolidityFunction
from smartfast.core.cfg.node import NodeType
from smartfast.smartir.operations import LowLevelCall
from smartfast.solc_parsing.variables.state_variable import StateVariableSolc, StateVariable
from smartfast.core.variables.local_variable import LocalVariable

# Reference: https://smartcontractsecurity.github.io/SWC-registry/docs/SWC-111
class DeprecatedStandards(AbstractDetector):
    """
    Use of Deprecated Standards
    """

    ARGUMENT = 'deprecated-standards'
    HELP = 'Deprecated Solidity Standards'
    IMPACT = DetectorClassification.INFORMATIONAL
    CONFIDENCE = DetectorClassification.EXACTLY

    WIKI = 'https://github.com/SmartContractTools/SmartFast/wiki/Detector-Documentation#deprecated-standards'

    WIKI_TITLE = 'Deprecated standards'
    WIKI_DESCRIPTION = 'Detect the usage of deprecated standards.'
    WIKI_EXPLOIT_SCENARIO = '''
```solidity
contract ContractWithDeprecatedReferences {
    // Deprecated: Change block.blockhash() -> blockhash()
    bytes32 globalBlockHash = block.blockhash(0);

    // Deprecated: Change constant -> view
    function functionWithDeprecatedThrow() public constant {
        // Deprecated: Change msg.gas -> gasleft()
        if(msg.gas == msg.value) {
            // Deprecated: Change throw -> revert()
            throw;
        }
    }

    // Deprecated: Change constant -> view
    function functionWithDeprecatedReferences() public constant {
        // Deprecated: Change sha3() -> keccak256()
        bytes32 sha3Result = sha3("test deprecated sha3 usage");

        // Deprecated: Change callcode() -> delegatecall()
        address(this).callcode();

        // Deprecated: Change suicide() -> selfdestruct()
        suicide(address(0));
    }
}
```'''

    WIKI_RECOMMENDATION = 'Replace all uses of deprecated symbols.'

    # The format for the following deprecated lists is [(detecting_signature, original_text, recommended_text)]
    DEPRECATED_SOLIDITY_VARIABLE = [("block.blockhash", "block.blockhash()", "blockhash()"),
                                    ("msg.gas", "msg.gas", "gasleft()")]
    DEPRECATED_SOLIDITY_FUNCTIONS = [("suicide(address)", "suicide()", "selfdestruct()"),
                                     ("sha3()", "sha3()", "keccak256()")]
    DEPRECATED_NODE_TYPES = [(NodeType.THROW, "throw", "revert()")]
    DEPRECATED_LOW_LEVEL_CALLS = [("callcode", "callcode", "delegatecall")]

    def detect_deprecation_in_expression(self, expression):
        """ Detects if an expression makes use of any deprecated standards.

        Returns:
            list of tuple: (detecting_signature, original_text, recommended_text)"""
        # Perform analysis on this expression
        # print(expression)
        export = ExportValues(expression)
        # print(export)
        export_values = export.result()
        # for ex in export_values:
        #     print(ex)
        #     print(type(ex))
        #     if isinstance(ex,LocalVariable):
        #         print("-----------type:")
        #         print(ex.type)
        # print("----")

        # Define our results list
        results = []

        # Check if there is usage of any deprecated solidity variables or functions
        for dep_var in self.DEPRECATED_SOLIDITY_VARIABLE:
            if SolidityVariableComposed(dep_var[0]) in export_values:
                results.append(dep_var)
        for dep_func in self.DEPRECATED_SOLIDITY_FUNCTIONS:
            if SolidityFunction(dep_func[0]) in export_values:
                results.append(dep_func)

        return results

    def detect_deprecated_references_in_node(self, node):
        """ Detects if a node makes use of any deprecated standards.

        Returns:
            list of tuple: (detecting_signature, original_text, recommended_text)"""
        # Define our results list
        results = []

        # If this node has an expression, we check the underlying expression.
        if node.expression:
            results += self.detect_deprecation_in_expression(node.expression)

        # Check if there is usage of any deprecated solidity variables or functions
        for dep_node in self.DEPRECATED_NODE_TYPES:
            if node.type == dep_node[0]:
                results.append(dep_node)

        return results

    def detect_deprecated_references_in_contract(self, contract):
        """ Detects the usage of any deprecated built-in symbols.

        Returns:
            list of tuple: (state_variable | node, (detecting_signature, original_text, recommended_text))"""
        results = []
        # print(contract.name)
        for state_variable in contract.state_variables_declared:
            # print(state_variable)
            # print(state_variable.type)
            # print(state_variable.node_initialization)
            if state_variable.expression:
                # print(state_variable.expression)
                deprecated_results = self.detect_deprecation_in_expression(state_variable.expression)
                if deprecated_results:
                    results.append((state_variable.node_initialization, deprecated_results)) #修改这里去除重复项

        # Loop through all functions + modifiers in this contract.
        for function in contract.functions_and_modifiers_declared:
            # print(function.name)
            # print(function._view)
            # Loop through each node in this function.
            for node in function.nodes:
                # Detect deprecated references in the node.
                # print(node)
                deprecated_results = self.detect_deprecated_references_in_node(node)

                # Detect additional deprecated low-level-calls.
                # print("---irs----")
                for ir in node.irs:
                    # print(ir)
                    # print(type(ir))
                    if isinstance(ir, LowLevelCall):
                        for dep_llc in self.DEPRECATED_LOW_LEVEL_CALLS:
                            if ir.function_name == dep_llc[0]:
                                deprecated_results.append(dep_llc)

                # If we have any results from this iteration, add them to our results list.
                if deprecated_results:
                    results.append((node, deprecated_results))

        return results

    def _detect(self):
        """ Detects if an expression makes use of any deprecated standards.

        Recursively visit the calls
        Returns:
            list: {'vuln', 'filename,'contract','func', 'deprecated_references'}

        """
        results = []
        for contract in self.contracts:
            deprecated_references = self.detect_deprecated_references_in_contract(contract)
            if deprecated_references:
                for deprecated_reference in deprecated_references:
                    source_object = deprecated_reference[0]
                    # print(source_object)
                    deprecated_entries = deprecated_reference[1]
                    info = ['Deprecated standard detected ', source_object, ':\n']

                    for (dep_id, original_desc, recommended_disc) in deprecated_entries:
                        info += [f"\t- Usage of \"{original_desc}\" should be replaced with \"{recommended_disc}\"\n"]

                    res = self.generate_result(info)
                    results.append(res)

        return results
