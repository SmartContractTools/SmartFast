"""
Module detecting tautologies and contradictions based on types in comparison operations over integers
"""

from smartfast.detectors.abstract_detector import AbstractDetector, DetectorClassification
from smartfast.smartir.operations import Binary, BinaryType,Assignment,Unpack
from smartfast.smartir.variables import Constant
from smartfast.core.solidity_types.elementary_type import Int, Uint
from smartfast.core.declarations.function import Function, FunctionType
import copy

class TypeBasedTautology(AbstractDetector):
    """
    Type-based tautology or contradiction
    """

    ARGUMENT = 'tautology'
    HELP = 'Tautology or contradiction'
    IMPACT = DetectorClassification.MEDIUM
    CONFIDENCE = DetectorClassification.EXACTLY

    WIKI = 'https://github.com/SmartContractTools/SmartFast/wiki/Detector-Documentation#tautology-or-contradiction'

    WIKI_TITLE = 'Tautology or contradiction'
    WIKI_DESCRIPTION = '''Detects expressions that are tautologies or contradictions.'''
    WIKI_EXPLOIT_SCENARIO = '''
```solidity
contract A {
	function f(uint x) public {
		// ...
        if (x >= 0) { // bad -- always true
           // ...
        }
		// ...
	}

	function g(uint8 y) public returns (bool) {
		// ...
        return (y < 512); // bad!
		// ...
	}
}
```
`x` is a `uint256`, so `x >= 0` will be always true.
`y` is a `uint8`, so `y <512` will be always true.  
'''

    WIKI_RECOMMENDATION = '''Fix the incorrect comparison by changing the value type or the comparison.'''

    def typeRange(self, t):
        bits = int(t.split("int")[1])
        if t in Uint:
            return (0, (2 ** bits) - 1)
        if t in Int:
            v = (2 ** (bits - 1)) - 1
            return (-v, v)


    flip_table = {
        BinaryType.GREATER: BinaryType.LESS,
        BinaryType.GREATER_EQUAL: BinaryType.LESS_EQUAL,
        BinaryType.LESS: BinaryType.GREATER,
        BinaryType.LESS_EQUAL: BinaryType.GREATER_EQUAL,
        BinaryType.EQUAL: BinaryType.EQUAL,
        BinaryType.NOT_EQUAL: BinaryType.NOT_EQUAL,
    }

    def _detect_tautology_or_contradiction(self, low, high, cval, op):
        '''
        Return true if "[low high] op cval " is always true or always false
        :param low:
        :param high:
        :param cval:
        :param op:
        :return:
        '''
        if op == BinaryType.LESS:
            # a < cval
            # its a tautology if
            # high(a) < cval
            # its a contradiction if
            # low(a) >= cval
            return high < cval or low >= cval
        elif op == BinaryType.GREATER:
            # a > cval
            # its a tautology if
            # low(a) > cval
            # its a contradiction if
            # high(a) <= cval
            return low > cval or high <= cval
        elif op == BinaryType.LESS_EQUAL:
            # a <= cval
            # its a tautology if
            # high(a) <= cval
            # its a contradiction if
            # low(a) > cval
            return (high <= cval) or (low > cval)
        elif op == BinaryType.GREATER_EQUAL:
            # a >= cval
            # its a tautology if
            # low(a) >= cval
            # its a contradiction if
            # high(a) < cval
            return (low >= cval) or (high < cval)
        elif op == BinaryType.EQUAL:
            # a >= cval
            # its a tautology if
            # low(a) >= cval
            # its a contradiction if
            # high(a) < cval
            return (low > cval) or (high < cval)
        elif op == BinaryType.NOT_EQUAL:
            # a >= cval
            # its a tautology if
            # low(a) >= cval
            # its a contradiction if
            # high(a) < cval
            return (low > cval) or (high < cval)
        return False

    def detect_type_based_tautologies(self, contract):
        """
        Detects and returns all nodes with tautology/contradiction comparisons (based on type alone).
        :param contract: Contract to detect assignment within.
        :return: A list of nodes with tautolgies/contradictions.
        """

        # Create our result set.
        results = []
        allInts = Int + Uint
        tains_not_bool_constant_base = {}

        for function in contract.all_functions_called:
            if function.function_type == FunctionType.CONSTRUCTOR_VARIABLES or function.function_type == FunctionType.CONSTRUCTOR_CONSTANT_VARIABLES or function.is_constructor:
                f_results = set()

                for node in function.nodes:
                    for ir in node.irs:
                        if isinstance(ir,Assignment):
                            if ir.lvalue.name in tains_not_bool_constant_base.keys():
                                tains_not_bool_constant_base.pop(ir.lvalue.name)
                            if isinstance(ir.rvalue, Constant) and str(ir.rvalue.type) in allInts:
                                tains_not_bool_constant_base[ir.lvalue.name] = ir.rvalue
                            if ir.rvalue.name in tains_not_bool_constant_base.keys():
                                tains_not_bool_constant_base[ir.lvalue.name] = tains_not_bool_constant_base[ir.rvalue.name]
                        elif isinstance(ir, Unpack):
                            unpack_lvalue = ir._lvalue
                            if unpack_lvalue.name in tains_not_bool_constant_base.keys():
                                tains_not_bool_constant_base.pop(ir.lvalue.name)
                        if isinstance(ir, Binary) and ir.type in self.flip_table:
                            if isinstance(ir.variable_left, Constant):
                                cval = ir.variable_left.value
                                rtype = str(ir.variable_right.type)
                                if rtype in allInts:
                                    (low, high) = self.typeRange(rtype)
                                    if self._detect_tautology_or_contradiction(low, high, cval, self.flip_table[ir.type]):
                                        f_results.add(node)
                            elif ir.variable_left.name in tains_not_bool_constant_base.keys():
                                cval = tains_not_bool_constant_base[ir.variable_left.name].value
                                rtype = str(ir.variable_right.type)
                                if rtype in allInts:
                                    (low, high) = self.typeRange(rtype)
                                    if self._detect_tautology_or_contradiction(low, high, cval, self.flip_table[ir.type]):
                                        f_results.add(node)
                            if isinstance(ir.variable_right, Constant):
                                cval = ir.variable_right.value
                                ltype = str(ir.variable_left.type)
                                if ltype in allInts:
                                    (low, high) = self.typeRange(ltype)
                                    if self._detect_tautology_or_contradiction(low, high, cval, ir.type):
                                        f_results.add(node)
                            elif ir.variable_right.name in tains_not_bool_constant_base.keys():
                                cval = tains_not_bool_constant_base[ir.variable_right.name].value
                                ltype = str(ir.variable_left.type)
                                if ltype in allInts:
                                    (low, high) = self.typeRange(ltype)
                                    if self._detect_tautology_or_contradiction(low, high, cval, ir.type):
                                        f_results.add(node)
                results.append((function, f_results))

        # Loop for each function and modifier.
        for function in contract.functions_and_modifiers_declared:
            if function.function_type == FunctionType.CONSTRUCTOR_VARIABLES or function.function_type == FunctionType.CONSTRUCTOR_CONSTANT_VARIABLES or function.is_constructor:
                continue
            tains_not_bool_constant = {}
            for v,m in tains_not_bool_constant_base.items():
                tains_not_bool_constant[v] = m
            # tains_not_bool_constant = copy.deepcopy(tains_not_bool_constant_base)
            # print(function.name)
            f_results = set()

            for node in function.nodes:
                # print(node)
                for ir in node.irs:
                    # print(ir)
                    # print(type(ir))
                    # if hasattr(ir,"type"):
                    #     print(ir.type)
                    #     for v in ir.get_variable:
                    #         print(v)
                    #         print(type(v))
                    if isinstance(ir,Assignment):
                        # print(type(ir.rvalue))
                        # print(type(ir.rvalue.value))
                        if ir.lvalue.name in tains_not_bool_constant.keys():
                            tains_not_bool_constant.pop(ir.lvalue.name)
                        if isinstance(ir.rvalue, Constant) and str(ir.rvalue.type) in allInts:
                            # print("HAHSHS")
                            # print(ir.rvalue)
                            tains_not_bool_constant[ir.lvalue.name] = ir.rvalue
                        if ir.rvalue.name in tains_not_bool_constant.keys():
                            tains_not_bool_constant[ir.lvalue.name] = tains_not_bool_constant[ir.rvalue.name]
                    elif isinstance(ir, Unpack):
                        unpack_lvalue = ir._lvalue
                        if unpack_lvalue.name in tains_not_bool_constant.keys():
                            tains_not_bool_constant.pop(ir.lvalue.name)
                    if isinstance(ir, Binary) and ir.type in self.flip_table:
                        # if (not BinaryType.return_bool(ir.type)) and ((isinstance(ir.variable_left, Constant) and type(ir.variable_left.value) in allInts) or ir.variable_left.name in tains_not_bool_constant) and\
                        #     ((isinstance(ir.variable_right, Constant) and type(ir.variable_right.value) in allInts) or ir.variable_right.name in tains_not_bool_constant):
                        #         tains_not_bool_constant[ir.lvalue.name] = 
                        # If neither side is a constant, we can't do much
                        # print(ir.variable_right.name)
                        if isinstance(ir.variable_left, Constant):
                            cval = ir.variable_left.value
                            rtype = str(ir.variable_right.type)
                            if rtype in allInts:
                                (low, high) = self.typeRange(rtype)
                                if self._detect_tautology_or_contradiction(low, high, cval, self.flip_table[ir.type]):
                                    f_results.add(node)
                        elif ir.variable_left.name in tains_not_bool_constant.keys():
                            cval = tains_not_bool_constant[ir.variable_left.name].value
                            rtype = str(ir.variable_right.type)
                            if rtype in allInts:
                                (low, high) = self.typeRange(rtype)
                                if self._detect_tautology_or_contradiction(low, high, cval, self.flip_table[ir.type]):
                                    f_results.add(node)

                        if isinstance(ir.variable_right, Constant):
                            cval = ir.variable_right.value
                            ltype = str(ir.variable_left.type)
                            if ltype in allInts:
                                (low, high) = self.typeRange(ltype)
                                if self._detect_tautology_or_contradiction(low, high, cval, ir.type):
                                    f_results.add(node)
                        elif ir.variable_right.name in tains_not_bool_constant.keys():
                            cval = tains_not_bool_constant[ir.variable_right.name].value
                            ltype = str(ir.variable_left.type)
                            if ltype in allInts:
                                (low, high) = self.typeRange(ltype)
                                if self._detect_tautology_or_contradiction(low, high, cval, ir.type):
                                    f_results.add(node)
            results.append((function, f_results))

        # Return the resulting set of nodes with tautologies and contradictions
        return results

    def _detect(self):
        """
        Detect tautological (or contradictory) comparisons
        """
        results = []
        for contract in self.contracts:
            tautologies = self.detect_type_based_tautologies(contract)
            if tautologies:
                for (func, nodes) in tautologies:
                    for node in nodes:
                        info = [func, " contains a tautology or contradiction:\n"]
                        info += ["\t- ", node, "\n"]

                        res = self.generate_result(info)
                        results.append(res)

        return results
