"""
    Module printing summary of the contract
"""

from smartfast.core.declarations import SolidityFunction
from smartfast.printers.abstract_printer import AbstractPrinter
from smartfast.smartir.operations import SolidityCall
from smartfast.utils.myprettytable import MyPrettyTable

require_or_assert = [
    SolidityFunction("assert(bool)"),
    SolidityFunction("require(bool)"),
    SolidityFunction("require(bool,string)"),
]


class RequireOrAssert(AbstractPrinter):

    ARGUMENT = "require"
    HELP = "Print the require and assert calls of each function"

    WIKI = "https://github.com/trailofbits/smartfast/wiki/Printer-documentation#require"

    @staticmethod
    def _convert(l):
        return "\n".join(l)

    def output(self, _filename):
        """
        _filename is not used
        Args:
            _filename(string)
        """

        all_tables = []
        all_txt = ""
        for contract in self.smartfast.contracts_derived:
            txt = "\nContract %s" % contract.name
            table = MyPrettyTable(["Function", "require or assert"])
            for function in contract.functions:
                require = function.all_smartir_operations()
                require = [
                    ir
                    for ir in require
                    if isinstance(ir, SolidityCall) and ir.function in require_or_assert
                ]
                require = [ir.node for ir in require]
                table.add_row(
                    [function.name, self._convert([str(m.expression) for m in set(require)]),]
                )
            txt += "\n" + str(table)
            self.info(txt)
            all_tables.append((contract.name, table))
            all_txt += txt

        res = self.generate_output(all_txt)
        for name, table in all_tables:
            res.add_pretty_table(table, name)

        return res
