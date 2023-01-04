from smartfast.detectors.abstract_detector import AbstractDetector, DetectorClassification
from smartfast.core.cfg.node import NodeType
from smartfast.smartir.operations import (Assignment,Unpack,Binary,TypeConversion,BinaryType,Condition)
from smartfast.smartir.variables import Constant
from smartfast.smartir.variables.temporary import TemporaryVariable


class IntegerOverflow(AbstractDetector):
    """
    Detect function named backdoor
    """

    ARGUMENT = 'integer-overflow'  # smartfast will launch the detector with smartfast.py --mydetector
    HELP = 'Integer operations are not reviewed'
    IMPACT = DetectorClassification.LOW
    CONFIDENCE = DetectorClassification.PROBABLY


    WIKI = 'https://github.com/trailofbits/smartfast/wiki/Integer-overflow'
    WIKI_TITLE = 'IntegerOverflow'
    WIKI_DESCRIPTION = 'Integer operations have not been reviewed, and overflows are prone to occur.'
    WIKI_EXPLOIT_SCENARIO = '''
```solidity
contract Intergeroverflow{
    function bad() {
        uint a;
        uint b;
        uint c = a + b;
    }
}
```'''
    WIKI_RECOMMENDATION = 'Use Safemath for integer arithmetic, or verify the calculated value.'

    def findinteger_overflow(self, contract):
        results = []

        # print(contract.name)
        # statevariable = contract.state_variables
        
        for f in contract.functions_and_modifiers_declared:
            if not f.is_implemented:
                continue
            # print(f.name)
            ret = []
            operationcheck = {}
            checkvalue = []

            for node in f.nodes:
                # print("node:")
                # print(node)
                # print(node.type)
                if set(['assert(bool)','require(bool)']).intersection([v.name for v in node.solidity_calls]):
                    checkvalue.append(node.variables_read)
                    # print([v.name for v in node.variables_read])
                for ir in node.irs:
                    # print(ir)
                    # print(type(ir))
                    if isinstance(ir,Condition):
                        checkvalue.append(node.variables_read)
                        # print([v.name for v in node.variables_read])
                    elif isinstance(ir, Assignment):
                        if isinstance(ir.rvalue,TemporaryVariable) and node in operationcheck:
                            for i in range(len(operationcheck[node])):
                                # print("444444")
                                # print(type(operationcheck[node][i]))
                                # print(ir.rvalue.name)
                                # print([v.name for v in operationcheck[node][i]])
                                # print(ir._lvalue.name)
                                if ir.rvalue in operationcheck[node][i]:
                                    operationcheck[node][i].append(ir._lvalue)
                    elif isinstance(ir, Binary) and not BinaryType.return_bool(ir.type):
                        if not (isinstance(ir.variable_left,TemporaryVariable) or isinstance(ir.variable_right,TemporaryVariable)):
                            if node not in operationcheck:
                                operationcheck[node] = []
                            # print("123")
                            readvalues = ir.read
                            # print(type(readvalues))
                            # print(readvalues)
                            readvalues.append(ir.lvalue)
                            # print(readvalues)
                            operationcheck[node].append(readvalues)
                            # print(operationcheck[node])
                        elif isinstance(ir.variable_left,TemporaryVariable) and not isinstance(ir.variable_right,TemporaryVariable):
                            if node in operationcheck:
                                for i in range(len(operationcheck[node])):
                                    if ir.variable_left in operationcheck[node][i]:
                                        operationcheck[node][i].append(ir.variable_right)
                                        operationcheck[node][i].append(ir.lvalue)
                                        break
                        elif not isinstance(ir.variable_left,TemporaryVariable) and isinstance(ir.variable_right,TemporaryVariable):
                            if node in operationcheck:
                                for i in range(len(operationcheck[node])):
                                    if ir.variable_right in operationcheck[node][i]:
                                        operationcheck[node][i].append(ir.variable_left)
                                        operationcheck[node][i].append(ir.lvalue)
                                        break
                        else:
                            if node in operationcheck:
                                for i in range(len(operationcheck[node])):
                                    if ir.variable_left in operationcheck[node][i]:
                                        for j in range(len(operationcheck[node])):
                                            if ir.variable_right in operationcheck[node][j]:
                                                operationcheck[node][i].extend(operationcheck[node][j])
                                                operationcheck[node][i].append(ir.lvalue)
                                                del(operationcheck[node][j])
                                                break
                                        break
                    elif isinstance(ir, TypeConversion):
                        if isinstance(ir.variable,TemporaryVariable) and node in operationcheck:
                            for i in range(len(operationcheck[node])):
                                if ir.variable in operationcheck[node][i]:
                                    operationcheck[node][i].append(ir.lvalue)
            # print("see checkvalue:")
            for node_val in operationcheck.keys():
                for i in range(len(operationcheck[node_val])-1,-1,-1):
                    operationvalue_set = set([v for v in operationcheck[node_val][i] if not isinstance(v,(TemporaryVariable,Constant))])
                    for checkvalue_val in checkvalue:
                        intersec_value = set(checkvalue_val).intersection(operationvalue_set)
                        # print("panduan:")
                        # print(node_val)
                        # print([v.name for v in operationvalue_set])
                        # print([v.name for v in checkvalue_val])
                        # print([v.name for v in intersec_value])
                        if intersec_value:
                            if len(operationvalue_set) >= 2 and len(checkvalue_val) >= 2:
                                if len(intersec_value) >= 2:
                                    del(operationcheck[node_val][i])
                                    break
                            else:
                                del(operationcheck[node_val][i])
                                break

            for node_val in operationcheck.keys():
                if operationcheck[node_val]:
                    ret.append(node_val)
                    # print("cuowu node:")
                    # print(node_val)
            if ret:
                results.append((f,ret))   
                # for ir in node.irs:
                #     print(ir)
                #     print(type(ir))
        return results

    def _detect(self):
        # print("***************")
        results = []

        for contract in self.smartfast.contracts:
            integer_overflow = self.findinteger_overflow(contract)
            for (func, nodes) in integer_overflow:

                info = [func, " may have integer overflow\n"]
                info += ['\tPossible nodes:\n']
                for node in nodes:
                    info += ['\t- ', node, '\n']

                res = self.generate_result(info)

                results.append(res)
        # print("***************")
        return results