from smartfast.detectors.abstract_detector import AbstractDetector, DetectorClassification
from smartfast.core.cfg.node import NodeType
from smartfast.smartir.operations import (Assignment,Unpack,Binary)
from smartfast.core.declarations.function import Function, FunctionType


class IncorrectInheritanceOrder(AbstractDetector):
    """
    Detect function named backdoor
    """

    ARGUMENT = 'incorrect-inheritance-order'  # smartfast will launch the detector with smartfast.py --mydetector
    HELP = 'Inherited variable conflict'
    IMPACT = DetectorClassification.LOW
    CONFIDENCE = DetectorClassification.PROBABLY


    WIKI = 'https://github.com/trailofbits/smartfast/wiki/IncorrectInheritanceOrder'
    WIKI_TITLE = 'IncorrectInheritanceOrder'
    WIKI_DESCRIPTION = 'There are conflicts in inherited variables, inherit in order of inheritance.'
    WIKI_EXPLOIT_SCENARIO = '''
```solidity
contract A {
     address owner;
}
contract B {
     address owner;
}
contract C is B,A{
}
```'''
    WIKI_RECOMMENDATION = 'Check the order of inheritance.'

    def findinheritanceorder(self, contract):
        results = []

        # print(contract.name)
        variables = []
        functions = []
        variables_conflicts = []
        functions_conflicts = []
        immediate_inheritance = contract.immediate_inheritance
        if not immediate_inheritance:
            return results
        for contract_inheritance in immediate_inheritance:
            variables.append(contract_inheritance.variables)
            functions.append([v for v in contract_inheritance.all_functions_called if v.function_type not in [FunctionType.CONSTRUCTOR_VARIABLES, FunctionType.CONSTRUCTOR_CONSTANT_VARIABLES, FunctionType.FALLBACK, FunctionType.CONSTRUCTOR]])
        for i in range(len(variables)):
            for j in range(i+1,len(variables)):
                for vi in variables[i]:
                    for vj in variables[j]:
                        if vi.name == vj.name:
                            variables_conflicts.extend([vi,vj])
                for fi in functions[i]:
                    for fj in functions[j]:
                        if fi.signature == fj.signature:
                            functions_conflicts.extend([fi,fj])
        conflicts_varandfunc = list(set(variables_conflicts))+list(set(functions_conflicts))
        if conflicts_varandfunc:
            results = conflicts_varandfunc

        return results

    def _detect(self):
        results = []
        # print("-------------------------------------")
        for contract in self.smartfast.contracts:
            inheritanceorder = self.findinheritanceorder(contract)
            if inheritanceorder:
                info = [contract, " inherits the contract, there is a conflict between state variables and functions\n"]
                info += ['\tConflicting functions and state variables:\n']
                for node in inheritanceorder:
                    info += ['\t- ', node, '\n']

                res = self.generate_result(info)
                results.append(res)
        # print("-------------------------------------")
        return results