"""
    Module printing evm mapping of the contract
"""
from smartfast.printers.abstract_printer import AbstractPrinter
from smartfast.analyses.evm import (
    generate_source_to_evm_ins_mapping,
    load_evm_cfg_builder,
)
from smartfast.utils.colors import blue, green, magenta, red


def _extract_evm_info(smartfast):
    """
    Extract evm information for all derived contracts using evm_cfg_builder

    Returns: evm CFG and Solidity source to Program Counter (pc) mapping
    """

    evm_info = {}

    CFG = load_evm_cfg_builder()

    for contract in smartfast.contracts_derived:
        contract_bytecode_runtime = smartfast.crytic_compile.bytecode_runtime(contract.name)
        contract_srcmap_runtime = smartfast.crytic_compile.srcmap_runtime(contract.name)
        cfg = CFG(contract_bytecode_runtime)
        evm_info["cfg", contract.name] = cfg
        evm_info["mapping", contract.name] = generate_source_to_evm_ins_mapping(
            cfg.instructions,
            contract_srcmap_runtime,
            smartfast,
            contract.source_mapping["filename_absolute"],
        )

        contract_bytecode_init = smartfast.crytic_compile.bytecode_init(contract.name)
        contract_srcmap_init = smartfast.crytic_compile.srcmap_init(contract.name)
        cfg_init = CFG(contract_bytecode_init)

        evm_info["cfg_init", contract.name] = cfg_init
        evm_info["mapping_init", contract.name] = generate_source_to_evm_ins_mapping(
            cfg_init.instructions,
            contract_srcmap_init,
            smartfast,
            contract.source_mapping["filename_absolute"],
        )

    return evm_info


class PrinterEVM(AbstractPrinter):
    ARGUMENT = "evm"
    HELP = "Print the evm instructions of nodes in functions"

    WIKI = "https://github.com/trailofbits/smartfast/wiki/Printer-documentation#evm"

    def output(self, _filename):
        """
        _filename is not used
        Args:
            _filename(string)
        """

        txt = ""

        if not self.smartfast.crytic_compile:
            txt = "The EVM printer requires to compile with crytic-compile"
            self.info(red(txt))
            res = self.generate_output(txt)
            return res
        evm_info = _extract_evm_info(self.smartfast)

        for contract in self.smartfast.contracts_derived:
            txt += blue("Contract {}\n".format(contract.name))

            contract_file = self.smartfast.source_code[
                contract.source_mapping["filename_absolute"]
            ].encode("utf-8")
            contract_file_lines = open(
                contract.source_mapping["filename_absolute"], "r"
            ).readlines()

            contract_pcs = {}
            contract_cfg = {}

            for function in contract.functions:
                txt += blue(f"\tFunction {function.canonical_name}\n")

                # CFG and source mapping depend on function being constructor or not
                if function.is_constructor:
                    contract_cfg = evm_info["cfg_init", contract.name]
                    contract_pcs = evm_info["mapping_init", contract.name]
                else:
                    contract_cfg = evm_info["cfg", contract.name]
                    contract_pcs = evm_info["mapping", contract.name]

                for node in function.nodes:
                    txt += green("\t\tNode: " + str(node) + "\n")
                    node_source_line = (
                        contract_file[0 : node.source_mapping["start"]].count("\n".encode("utf-8"))
                        + 1
                    )
                    txt += green(
                        "\t\tSource line {}: {}\n".format(
                            node_source_line, contract_file_lines[node_source_line - 1].rstrip(),
                        )
                    )
                    txt += magenta("\t\tEVM Instructions:\n")
                    node_pcs = contract_pcs.get(node_source_line, [])
                    for pc in node_pcs:
                        txt += magenta(
                            "\t\t\t0x{:x}: {}\n".format(
                                int(pc), contract_cfg.get_instruction_at(pc)
                            )
                        )

            for modifier in contract.modifiers:
                txt += blue(f"\tModifier {modifier.canonical_name}\n")
                for node in modifier.nodes:
                    txt += green("\t\tNode: " + str(node) + "\n")
                    node_source_line = (
                        contract_file[0 : node.source_mapping["start"]].count("\n".encode("utf-8"))
                        + 1
                    )
                    txt += green(
                        "\t\tSource line {}: {}\n".format(
                            node_source_line, contract_file_lines[node_source_line - 1].rstrip(),
                        )
                    )
                    txt += magenta("\t\tEVM Instructions:\n")
                    node_pcs = contract_pcs.get(node_source_line, [])
                    for pc in node_pcs:
                        txt += magenta(
                            "\t\t\t0x{:x}: {}\n".format(
                                int(pc), contract_cfg.get_instruction_at(pc)
                            )
                        )

        self.info(txt)
        res = self.generate_output(txt)
        return res
