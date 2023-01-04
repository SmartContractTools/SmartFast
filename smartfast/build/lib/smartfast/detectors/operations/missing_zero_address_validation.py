"""
Module detecting missing zero address validation

"""
from collections import defaultdict

from smartfast.detectors.abstract_detector import AbstractDetector, DetectorClassification
from smartfast.analyses.data_dependency.data_dependency import is_tainted
from smartfast.core.solidity_types.elementary_type import ElementaryType
from smartfast.smartir.operations import Send, Transfer, LowLevelCall
from smartfast.smartir.operations import Call


class MissingZeroAddressValidation(AbstractDetector):
    """
    Missing zero address validation
    """

    ARGUMENT = "missing-zero-check"
    HELP = "Missing Zero Address Validation"
    IMPACT = DetectorClassification.LOW
    CONFIDENCE = DetectorClassification.PROBABLY

    WIKI = "https://github.com/SmartContractTools/SmartFast/wiki/Detector-Documentation#missing-zero-address-validation"
    WIKI_TITLE = "Missing zero address validation"
    WIKI_DESCRIPTION = "Detect missing zero address validation."
    WIKI_EXPLOIT_SCENARIO = """
```solidity
contract C {

  modifier onlyAdmin {
    if (msg.sender != owner) throw;
    _;
  }

  function updateOwner(address newOwner) onlyAdmin external {
    owner = newOwner;
  }
}
```
Bob calls `updateOwner` without specifying the `newOwner`, soBob loses ownership of the contract.
"""

    WIKI_RECOMMENDATION = "Check that the address is not zero."

    def _zero_address_validation_in_modifier(self, var, modifier_exprs):
        for mod in modifier_exprs:
            for node in mod.nodes:
                # Skip validation if the modifier's parameters contains more than one variable
                # For example
                # function f(a) my_modif(some_internal_function(a, b)) {
                if len(node.irs) != 1:
                    continue
                args = [arg for ir in node.irs if isinstance(ir, Call) for arg in ir.arguments]
                # Check in modifier call arguments and then identify validation of corresponding parameter within modifier context
                if var in args and self._zero_address_validation(
                    mod.modifier.parameters[args.index(var)], mod.modifier.nodes[-1], []
                ):
                    return True
        return False

    def _zero_address_validation(self, var, node, explored):
        """
        Detects (recursively) if var is (zero address) checked in the function node
        """
        if node in explored:
            return False
        explored.append(node)

        # Heuristic: Assume zero address checked if variable is used within conditional or require/assert
        # TBD: Actually check for zero address in predicate
        if (node.contains_if() or node.contains_require_or_assert()) and (
            var in node.variables_read
        ):
            return True

        # Check recursively in all the parent nodes
        for father in node.fathers:
            if self._zero_address_validation(var, father, explored):
                return True
        return False

    def _detect_missing_zero_address_validation(self, contract):
        """
        Detects if addresses are zero address validated before use.
        :param contract: The contract to check
        :return: Functions with nodes where addresses used are not zero address validated earlier
        """
        results = []

        for function in contract.functions_entry_points:
            var_nodes = defaultdict(list)

            for node in function.nodes:
                sv_addrs_written = [
                    sv
                    for sv in node.state_variables_written
                    if sv.type == ElementaryType("address")
                ]

                addr_calls = False
                for ir in node.irs:
                    if isinstance(ir, (Send, Transfer, LowLevelCall)):
                        addr_calls = True

                # Continue if no address-typed state variables are written and if no send/transfer/call
                if not sv_addrs_written and not addr_calls:
                    continue

                # Check local variables used in such nodes
                for var in node.local_variables_read:
                    # Check for address types that are tainted but not by msg.sender
                    if var.type == ElementaryType("address") and is_tainted(
                        var, function, ignore_generic_taint=True
                    ):
                        # Check for zero address validation of variable
                        # in the context of modifiers used or prior function context
                        if not (
                            self._zero_address_validation_in_modifier(
                                var, function.modifiers_statements
                            )
                            or self._zero_address_validation(var, node, [])
                        ):
                            # Report a variable only once per function
                            var_nodes[var].append(node)
            if var_nodes:
                results.append((function, var_nodes))
        return results

    def _detect(self):
        """Detect if addresses are zero address validated before use.
        Returns:
            list: {'(function, node)'}
        """

        # Check derived contracts for missing zero address validation
        results = []
        for contract in self.smartfast.contracts_derived:
            missing_zero_address_validation = self._detect_missing_zero_address_validation(contract)
            for (_, var_nodes) in missing_zero_address_validation:
                for var, nodes in var_nodes.items():
                    info = [var, " lacks a zero-check on ", ":\n"]
                    for node in nodes:
                        info += ["\t\t- ", node, "\n"]
                    res = self.generate_result(info)
                    results.append(res)
        return results
