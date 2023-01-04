"""
Module detecting misuse of Boolean constants
"""
from smartfast.core.cfg.node import NodeType
from smartfast.core.solidity_types import ElementaryType
from smartfast.detectors.abstract_detector import AbstractDetector, DetectorClassification
from smartfast.smartir.operations import Assignment, Call, Return, InitArray, Binary, BinaryType, Condition,Unpack,Unary
from smartfast.smartir.variables import Constant
from smartfast.core.declarations.function import Function, FunctionType
import copy


class BooleanConstantMisuse(AbstractDetector):
    """
    Boolean constant misuse
    """

    ARGUMENT = 'boolean-cst'
    HELP = 'Misuse of Boolean constant'
    IMPACT = DetectorClassification.MEDIUM
    CONFIDENCE = DetectorClassification.PROBABLY

    WIKI = 'https://github.com/SmartContractTools/SmartFast/wiki/Detector-Documentation#misuse-of-a-boolean-constant'

    WIKI_TITLE = 'Misuse of a Boolean constant'
    WIKI_DESCRIPTION = '''Detects the misuse of a Boolean constant.'''
    WIKI_EXPLOIT_SCENARIO = '''
```solidity
contract A {
	function f(uint x) public {
		// ...
        if (false) { // bad!
           // ...
        }
		// ...
	}

	function g(bool b) public returns (bool) {
		// ...
        return (b || true); // bad!
		// ...
	}
}
```
Boolean constants in code have only a few legitimate uses. 
Other uses (in complex expressions, as conditionals) indicate either an error or, most likely, the persistence of faulty code.'''

    WIKI_RECOMMENDATION = '''Verify and simplify the condition.'''

    @staticmethod
    def _detect_boolean_constant_misuses(contract):
        """
        Detects and returns all nodes which misuse a Boolean constant.
        :param contract: Contract to detect assignment within.
        :return: A list of misusing nodes.
        """

        # Create our result set.
        results = []
        # print(contract.name)
        tains_bool_constant_base = []
        # Loop for each function and modifier.
        for function in contract.all_functions_called:
            if function.function_type == FunctionType.CONSTRUCTOR_VARIABLES or function.function_type == FunctionType.CONSTRUCTOR_CONSTANT_VARIABLES or function.is_constructor:
                f_results = set()
                in_loop = False
                whiletrue = None
                # Loop for every node in this function, looking for boolean constants
                for node in function.nodes:
                    if node.type == NodeType.STARTLOOP:
                        in_loop = True
                    elif node.type == NodeType.ENDLOOP:
                        in_loop = False
                        if whiletrue:
                            f_results.add(whiletrue)
                    elif node.type == NodeType.IFLOOP:
                        if node.irs:
                            if len(node.irs) == 1:
                                ir = node.irs[0]
                                if isinstance(ir, Condition) and ir.value == Constant('True', ElementaryType('bool')):
                                    whiletrue = node
                                    continue
                    elif (node.type == NodeType.BREAK or node.type == NodeType.RETURN) and in_loop:
                        whiletrue = None

                    for ir in node.irs:
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
                        if isinstance(ir, (Assignment, Call, Return, InitArray)):
                            continue
                        if isinstance(ir, Binary):
                            if BinaryType.return_bool(ir.type) and (isinstance(ir.variable_left, Constant) or ir.variable_left.name in tains_bool_constant_base) and\
                                (isinstance(ir.variable_right, Constant) or ir.variable_right.name in tains_bool_constant_base):
                                    tains_bool_constant_base.append(ir.lvalue.name)
                            if ir.type in [BinaryType.ADDITION, BinaryType.EQUAL, BinaryType.NOT_EQUAL]:
                                continue
                        for r in ir.read:
                            if (isinstance(r, Constant) and type(r.value) is bool) or r.name in tains_bool_constant_base:
                                f_results.add(node)
                if f_results:
                    results.append((function, f_results))
        for function in contract.functions_and_modifiers_declared:
            if function.function_type == FunctionType.CONSTRUCTOR_VARIABLES or function.function_type == FunctionType.CONSTRUCTOR_CONSTANT_VARIABLES or function.is_constructor:
                continue
            tains_bool_constant = copy.deepcopy(tains_bool_constant_base)
            f_results = set()
            in_loop = False
            whiletrue = None
            # print(function.name)
            # Loop for every node in this function, looking for boolean constants
            for node in function.nodes:
                # print(node)
                # print(node.type)
                # Do not report "while(true)"
                if node.type == NodeType.STARTLOOP:
                    in_loop = True
                elif node.type == NodeType.ENDLOOP:
                    in_loop = False
                    # print("----xianshi--------")
                    if whiletrue:
                        # print("-------iaminwhile")
                        f_results.add(whiletrue)
                elif node.type == NodeType.IFLOOP:
                    if node.irs:
                        if len(node.irs) == 1:
                            ir = node.irs[0]
                            # print(ir)
                            # print(ir.value)
                            if isinstance(ir, Condition) and ir.value == Constant('True', ElementaryType('bool')):
                                whiletrue = node
                                continue
                elif (node.type == NodeType.BREAK or node.type == NodeType.RETURN) and in_loop:
                    whiletrue = None

                for ir in node.irs:
                    # print(ir)
                    # print("::::::")
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
                    if isinstance(ir, (Assignment, Call, Return, InitArray)):
                        # It's ok to use a bare boolean constant in these contexts
                        continue
                    if isinstance(ir, Binary):
                        if BinaryType.return_bool(ir.type) and (isinstance(ir.variable_left, Constant) or ir.variable_left.name in tains_bool_constant) and\
                                (isinstance(ir.variable_right, Constant) or ir.variable_right.name in tains_bool_constant):
                                    tains_bool_constant.append(ir.lvalue.name)
                        if ir.type in [BinaryType.ADDITION, BinaryType.EQUAL, BinaryType.NOT_EQUAL]:
                            # Comparing to a Boolean constant is dubious style, but harmless
                            # Equal is catch by another detector (informational severity)
                            continue
                    for r in ir.read:
                        if (isinstance(r, Constant) and type(r.value) is bool) or r.name in tains_bool_constant:
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
            boolean_constant_misuses = self._detect_boolean_constant_misuses(contract)
            if boolean_constant_misuses:
                for (func, nodes) in boolean_constant_misuses:
                    for node in nodes:
                        info = [func, " uses a Boolean constant improperly:\n\t-", node, "\n"]

                        res = self.generate_result(info)
                        results.append(res)
                
        return results
