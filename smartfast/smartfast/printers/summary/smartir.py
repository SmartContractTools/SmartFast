"""
    Module printing summary of the contract
"""
from smartfast.core.declarations import Function
from smartfast.printers.abstract_printer import AbstractPrinter


def _print_function(function: Function) -> str:
    txt = ""
    for node in function.nodes:
        if node.expression:
            txt += "\t\tExpression: {}\n".format(node.expression)
            txt += "\t\tIRs:\n"
            for ir in node.irs:
                txt += "\t\t\t{}\n".format(ir)
        elif node.irs:
            txt += "\t\tIRs:\n"
            for ir in node.irs:
                txt += "\t\t\t{}\n".format(ir)
    return txt


class PrinterSmartIR(AbstractPrinter):
    ARGUMENT = "smartir"
    HELP = "Print the smartIR representation of the functions"

    WIKI = "https://github.com/trailofbits/smartfast/wiki/Printer-documentation#smartir"

    def output(self, _filename):
        """
        _filename is not used
        Args:
            _filename(string)
        """

        txt = ""
        for contract in self.contracts:
            if contract.is_top_level:
                continue
            txt += "Contract {}\n".format(contract.name)
            for function in contract.functions:
                txt = f'\tFunction {function.canonical_name} {"" if function.is_shadowed else "(*)"}\n'
                txt += _print_function(function)
            for modifier in contract.modifiers:
                txt += "\tModifier {}\n".format(modifier.canonical_name)
                txt += _print_function(modifier)
        if self.smartfast.functions_top_level:
            txt += "Top level functions"
        for function in self.smartfast.functions_top_level:
            txt += f"\tFunction {function.canonical_name}\n"
            txt += _print_function(function)
        self.info(txt)
        res = self.generate_output(txt)
        return res
