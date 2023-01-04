"""
Module detecting misuse of Boolean constants
"""

from smartfast.detectors.abstract_detector import AbstractDetector, DetectorClassification
from smartfast.smartir.operations import Assignment, Call, Return, InitArray, Binary, BinaryType,Unpack,Unary
from smartfast.smartir.variables import Constant
from smartfast.core.declarations.function import Function, FunctionType
import copy


class BooleanEquality(AbstractDetector):
    """
    Boolean constant misuse
    """

    ARGUMENT = 'boolean-equal'
    HELP = 'Comparison to boolean constant'
    IMPACT = DetectorClassification.OPTIMIZATION
    CONFIDENCE = DetectorClassification.EXACTLY

    WIKI = 'https://github.com/SmartContractTools/SmartFast/wiki/Detector-Documentation#boolean-equality'

    WIKI_TITLE = 'Boolean equality'
    WIKI_DESCRIPTION = '''Detects the comparison to boolean constants.'''
    WIKI_EXPLOIT_SCENARIO = '''
```solidity
contract A {
	function f(bool x) public {
		// ...
        if (x == true) { // bad!
           // ...
        }
		// ...
	}
}
```
Boolean constants can be used directly and do not need to be compare to `true` or `false`.'''

    WIKI_RECOMMENDATION = '''Remove the equality to the boolean constant.'''

    @staticmethod
    def _detect_boolean_equality(contract):

        # Create our result set.
        results = []
        tains_bool_constant_base = []

        # Loop for each function and modifier.
        for function in contract.all_functions_called:
            # print(function.name)
            # print(function.function_type)
            # if(function.is_constructor):
                # print("---------********---------")
            if function.function_type == FunctionType.CONSTRUCTOR_VARIABLES or function.function_type == FunctionType.CONSTRUCTOR_CONSTANT_VARIABLES or function.is_constructor:
                f_results = set()

                # Loop for every node in this function, looking for boolean constants
                for node in function.nodes:
                    # print(node)
                    for ir in node.irs:
                        # print(ir)
                        # print(type(ir))
                        if isinstance(ir,Assignment):
                            if ir.lvalue.name in tains_bool_constant_base:
                                tains_bool_constant_base.remove(ir.lvalue.name)
                            if isinstance(ir.rvalue, Constant) and type(ir.rvalue.value) is bool:
                                tains_bool_constant_base.append(ir.lvalue.name)
                            elif ir.rvalue.name in tains_bool_constant_base:
                                tains_bool_constant_base.append(ir.lvalue.name)
                        elif isinstance(ir, Unpack):
                            unpack_lvalue = ir._lvalue
                            if unpack_lvalue.name in tains_bool_constant_base:
                                tains_bool_constant_base.remove(ir.lvalue.name)
                        elif isinstance(ir, Unary):
                            if isinstance(ir.rvalue, Constant) or ir.rvalue.name in tains_bool_constant_base:
                                tains_bool_constant_base.append(ir.lvalue.name)
                        elif isinstance(ir, Binary):
                            if BinaryType.return_bool(ir.type) and (isinstance(ir.variable_left, Constant) or ir.variable_left.name in tains_bool_constant_base) and\
                                (isinstance(ir.variable_right, Constant) or ir.variable_right.name in tains_bool_constant_base):
                                    tains_bool_constant_base.append(ir.lvalue.name)
                            if ir.type in [BinaryType.EQUAL, BinaryType.NOT_EQUAL]:
                                for r in ir.read:
                                    if isinstance(r, Constant):
                                        if type(r.value) is bool:
                                            f_results.add(node)
                                    elif r.name in tains_bool_constant_base:
                                        f_results.add(node)
                if f_results:
                    results.append((function, f_results))
                # print("-----------")

        for function in contract.functions_and_modifiers_declared:
            if function.function_type == FunctionType.CONSTRUCTOR_VARIABLES or function.function_type == FunctionType.CONSTRUCTOR_CONSTANT_VARIABLES or function.is_constructor:
                continue
            # print(function.name)
            f_results = set()
            tains_bool_constant = copy.deepcopy(tains_bool_constant_base)
            # Loop for every node in this function, looking for boolean constants
            for node in function.nodes:
                # print(node)
                for ir in node.irs:
                    # print(ir)
                    # print(type(ir))
                    if isinstance(ir,Assignment):
                        if ir.lvalue.name in tains_bool_constant:
                            tains_bool_constant.remove(ir.lvalue.name)
                        if isinstance(ir.rvalue, Constant) and type(ir.rvalue.value) is bool:
                            tains_bool_constant.append(ir.lvalue.name)
                        elif ir.rvalue.name in tains_bool_constant:
                            tains_bool_constant.append(ir.lvalue.name)
                    elif isinstance(ir, Unpack):
                        unpack_lvalue = ir._lvalue
                        if unpack_lvalue.name in tains_bool_constant:
                            tains_bool_constant.remove(ir.lvalue.name)
                    elif isinstance(ir, Unary):
                        if isinstance(ir.rvalue, Constant) or ir.rvalue.name in tains_bool_constant:
                            tains_bool_constant.append(ir.lvalue.name)
                    elif isinstance(ir, Binary):
                        if BinaryType.return_bool(ir.type) and (isinstance(ir.variable_left, Constant) or ir.variable_left.name in tains_bool_constant) and\
                                (isinstance(ir.variable_right, Constant) or ir.variable_right.name in tains_bool_constant):
                                    tains_bool_constant.append(ir.lvalue.name)
                        if ir.type in [BinaryType.EQUAL, BinaryType.NOT_EQUAL]:
                            for r in ir.read:
                                if isinstance(r, Constant):
                                    if type(r.value) is bool:
                                        f_results.add(node)
                                elif r.name in tains_bool_constant:
                                    f_results.add(node)
            if f_results:
                results.append((function, f_results))

        # Return the resulting set of nodes with improper uses of Boolean constants
        return results

    def _detect(self):
        """
        Detect Boolean constant misuses
        """
        results = []
        for contract in self.contracts:
            boolean_constant_misuses = self._detect_boolean_equality(contract)
            if boolean_constant_misuses:
                for (func, nodes) in boolean_constant_misuses:
                    for node in nodes:
                        info = [func, " compares to a boolean constant:\n\t-", node, "\n"]

                        res = self.generate_result(info)
                        results.append(res)

        return results
