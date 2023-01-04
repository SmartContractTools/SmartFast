"""
    Module printing summary of the contract
"""

from smartfast.printers.abstract_printer import AbstractPrinter


class PrinterSmartIRSSA(AbstractPrinter):

    ARGUMENT = "smartir-ssa"
    HELP = "Print the smartIR representation of the functions"

    WIKI = "https://github.com/trailofbits/smartfast/wiki/Printer-documentation#smartir-ssa"

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
            txt += "Contract {}".format(contract.name) + "\n"
            for function in contract.functions:
                txt += "\tFunction {}".format(function.canonical_name) + "\n"
                for node in function.nodes:
                    if node.expression:
                        txt += "\t\tExpression: {}".format(node.expression) + "\n"
                    if node.irs_ssa:
                        txt += "\t\tIRs:" + "\n"
                        for ir in node.irs_ssa:
                            txt += "\t\t\t{}".format(ir) + "\n"
            for modifier in contract.modifiers:
                txt += "\tModifier {}".format(modifier.canonical_name) + "\n"
                for node in modifier.nodes:
                    txt += str(node) + "\n"
                    if node.expression:
                        txt += "\t\tExpression: {}".format(node.expression) + "\n"
                    if node.irs_ssa:
                        txt += "\t\tIRs:" + "\n"
                        for ir in node.irs_ssa:
                            txt += "\t\t\t{}".format(ir) + "\n"
        self.info(txt)
        res = self.generate_output(txt)
        return res
