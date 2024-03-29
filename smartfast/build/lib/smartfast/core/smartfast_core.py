"""
    Main module
"""
import json
import logging
import math
import os
import re
from collections import defaultdict
from typing import Optional, Dict, List, Set, Union, Tuple

from crytic_compile import CryticCompile

from smartfast.core.context.context import Context
from smartfast.core.declarations import (
    Contract,
    Pragma,
    Import,
    Function,
    Modifier,
)
from smartfast.core.declarations.enum_top_level import EnumTopLevel
from smartfast.core.declarations.function_top_level import FunctionTopLevel
from smartfast.core.declarations.structure_top_level import StructureTopLevel
from smartfast.core.variables.state_variable import StateVariable
from smartfast.core.variables.top_level_variable import TopLevelVariable
from smartfast.smartir.operations import InternalCall
from smartfast.smartir.variables import Constant
from smartfast.utils.colors import red

logger = logging.getLogger("Smartfast")
logging.basicConfig()


def _relative_path_format(path: str) -> str:
    """
    Strip relative paths of "." and ".."
    """
    return path.split("..")[-1].strip(".").strip("/")


class SmartfastCore(Context):  # pylint: disable=too-many-instance-attributes,too-many-public-methods
    """
    Smartfast static analyzer
    """

    def __init__(self):
        super().__init__()

        # Top level object
        self._contracts: Dict[str, Contract] = {}
        self._structures_top_level: List[StructureTopLevel] = []
        self._enums_top_level: List[EnumTopLevel] = []
        self._variables_top_level: List[TopLevelVariable] = []
        self._functions_top_level: List[FunctionTopLevel] = []
        self._pragma_directives: List[Pragma] = []
        self._import_directives: List[Import] = []

        self._filename: Optional[str] = None
        self._source_units: Dict[int, str] = {}
        self._solc_version: Optional[str] = None  # '0.3' or '0.4':!
        self._raw_source_code: Dict[str, str] = {}
        self._source_code_to_line: Optional[Dict[str, List[str]]] = None
        self._all_functions: Set[Function] = set()
        self._all_modifiers: Set[Modifier] = set()
        # Memoize
        self._all_state_variables: Optional[Set[StateVariable]] = None

        self._previous_results_filename: str = "smartfast.db.json"
        self._results_to_hide: List = []
        self._previous_results: List = []
        self._previous_results_ids: Set[str] = set()
        self._paths_to_filter: Set[str] = set()

        self._crytic_compile: Optional[CryticCompile] = None

        self._generate_patches = False
        self._exclude_dependencies = False

        self._markdown_root = ""

        self._contract_name_collisions = defaultdict(list)
        self._contract_with_missing_inheritance = set()

        self._storage_layouts: Dict[str, Dict[str, Tuple[int, int]]] = {}

        # If set to true, smartfast will not catch errors during parsing
        self._disallow_partial: bool = False
        self._skip_assembly: bool = False

        self._show_ignored_findings = False

    ###################################################################################
    ###################################################################################
    # region Source code
    ###################################################################################
    ###################################################################################

    @property
    def source_code(self) -> Dict[str, str]:
        """ {filename: source_code (str)}: source code """
        return self._raw_source_code

    @property
    def source_units(self) -> Dict[int, str]:
        return self._source_units

    @property
    def filename(self) -> Optional[str]:
        """str: Filename."""
        return self._filename

    @filename.setter
    def filename(self, filename: str):
        self._filename = filename

    def add_source_code(self, path):
        """
        :param path:
        :return:
        """
        if self.crytic_compile and path in self.crytic_compile.src_content:
            self.source_code[path] = self.crytic_compile.src_content[path]
        else:
            with open(path, encoding="utf8", newline="") as f:
                self.source_code[path] = f.read()

    @property
    def markdown_root(self) -> str:
        return self._markdown_root

    # endregion
    ###################################################################################
    ###################################################################################
    # region Pragma attributes
    ###################################################################################
    ###################################################################################

    @property
    def solc_version(self) -> str:
        """str: Solidity version."""
        if self.crytic_compile:
            return self.crytic_compile.compiler_version.version
        return self._solc_version

    @solc_version.setter
    def solc_version(self, version: str):
        self._solc_version = version

    @property
    def pragma_directives(self) -> List[Pragma]:
        """ list(core.declarations.Pragma): Pragma directives."""
        return self._pragma_directives

    @property
    def import_directives(self) -> List[Import]:
        """ list(core.declarations.Import): Import directives"""
        return self._import_directives

    # endregion
    ###################################################################################
    ###################################################################################
    # region Contracts
    ###################################################################################
    ###################################################################################

    @property
    def contracts(self) -> List[Contract]:
        """list(Contract): List of contracts."""
        return list(self._contracts.values())

    @property
    def contracts_derived(self) -> List[Contract]:
        """list(Contract): List of contracts that are derived and not inherited."""
        inheritance = (x.inheritance for x in self.contracts)
        inheritance = [item for sublist in inheritance for item in sublist]
        return [c for c in self._contracts.values() if c not in inheritance and not c.is_top_level]

    @property
    def contracts_as_dict(self) -> Dict[str, Contract]:
        """list(dict(str: Contract): List of contracts as dict: name -> Contract."""
        return self._contracts

    def get_contract_from_name(self, contract_name: Union[str, Constant]) -> Optional[Contract]:
        """
            Return a contract from a name
        Args:
            contract_name (str): name of the contract
        Returns:
            Contract
        """
        return next((c for c in self.contracts if c.name == contract_name), None)

    # endregion
    ###################################################################################
    ###################################################################################
    # region Functions and modifiers
    ###################################################################################
    ###################################################################################

    @property
    def functions(self) -> List[Function]:
        return list(self._all_functions)

    def add_function(self, func: Function):
        self._all_functions.add(func)

    @property
    def modifiers(self) -> List[Modifier]:
        return list(self._all_modifiers)

    def add_modifier(self, modif: Modifier):
        self._all_modifiers.add(modif)

    @property
    def functions_and_modifiers(self) -> List[Function]:
        return self.functions + self.modifiers

    def propagate_function_calls(self):
        for f in self.functions_and_modifiers:
            for node in f.nodes:
                for ir in node.irs_ssa:
                    if isinstance(ir, InternalCall):
                        ir.function.add_reachable_from_node(node, ir)

    # endregion
    ###################################################################################
    ###################################################################################
    # region Variables
    ###################################################################################
    ###################################################################################

    @property
    def state_variables(self) -> List[StateVariable]:
        if self._all_state_variables is None:
            state_variables = [c.state_variables for c in self.contracts]
            state_variables = [item for sublist in state_variables for item in sublist]
            self._all_state_variables = set(state_variables)
        return list(self._all_state_variables)

    # endregion
    ###################################################################################
    ###################################################################################
    # region Top level
    ###################################################################################
    ###################################################################################

    @property
    def structures_top_level(self) -> List[StructureTopLevel]:
        return self._structures_top_level

    @property
    def enums_top_level(self) -> List[EnumTopLevel]:
        return self._enums_top_level

    @property
    def variables_top_level(self) -> List[TopLevelVariable]:
        return self._variables_top_level

    @property
    def functions_top_level(self) -> List[FunctionTopLevel]:
        return self._functions_top_level

    # endregion
    ###################################################################################
    ###################################################################################
    # region Export
    ###################################################################################
    ###################################################################################

    def print_functions(self, d: str):
        """
        Export all the functions to dot files
        """
        for c in self.contracts:
            for f in c.functions:
                f.cfg_to_dot(os.path.join(d, "{}.{}.dot".format(c.name, f.name)))

    # endregion
    ###################################################################################
    ###################################################################################
    # region Filtering results
    ###################################################################################
    ###################################################################################

    def has_ignore_comment(self, r: Dict) -> bool:
        """
        Check if the result has an ignore comment on the proceeding line, in which case, it is not valid
        """
        if not self.crytic_compile:
            return False
        mapping_elements_with_lines = (
            (
                os.path.normpath(elem["source_mapping"]["filename_absolute"]),
                elem["source_mapping"]["lines"],
            )
            for elem in r["elements"]
            if "source_mapping" in elem
            and "filename_absolute" in elem["source_mapping"]
            and "lines" in elem["source_mapping"]
            and len(elem["source_mapping"]["lines"]) > 0
        )

        for file, lines in mapping_elements_with_lines:
            ignore_line_index = min(lines) - 1
            ignore_line_text = self.crytic_compile.get_code_from_line(file, ignore_line_index)
            if ignore_line_text:
                match = re.findall(
                    r"^\s*//\s*smartfast-disable-next-line\s*([a-zA-Z0-9_,-]*)",
                    ignore_line_text.decode("utf8"),
                )
                if match:
                    ignored = match[0].split(",")
                    if ignored and ("all" in ignored or any(r["check"] == c for c in ignored)):
                        return True

        return False

    def valid_result(self, r: Dict) -> bool:
        """
        Check if the result is valid
        A result is invalid if:
            - All its source paths belong to the source path filtered
            - Or a similar result was reported and saved during a previous run
            - The --exclude-dependencies flag is set and results are only related to dependencies
            - There is an ignore comment on the preceding line
        """
        source_mapping_elements = [
            elem["source_mapping"].get("filename_absolute", "unknown")
            for elem in r["elements"]
            if "source_mapping" in elem
        ]
        source_mapping_elements = map(
            lambda x: os.path.normpath(x) if x else x, source_mapping_elements
        )
        matching = False

        for path in self._paths_to_filter:
            try:
                if any(
                    bool(re.search(_relative_path_format(path), src_mapping))
                    for src_mapping in source_mapping_elements
                ):
                    matching = True
                    break
            except re.error:
                logger.error(
                    f"Incorrect regular expression for --filter-paths {path}."
                    "\nSmartfast supports the Python re format"
                    ": https://docs.python.org/3/library/re.html"
                )

        if r["elements"] and matching:
            return False
        if r["elements"] and self._exclude_dependencies:
            return not all(element["source_mapping"]["is_dependency"] for element in r["elements"])
        if self._show_ignored_findings:
            return True
        if r["id"] in self._previous_results_ids:
            return False
        if self.has_ignore_comment(r):
            return False
        # Conserve previous result filtering. This is conserved for compatibility, but is meant to be removed
        return not r["description"] in [pr["description"] for pr in self._previous_results]

    def load_previous_results(self):
        filename = self._previous_results_filename
        try:
            if os.path.isfile(filename):
                with open(filename) as f:
                    self._previous_results = json.load(f)
                    if self._previous_results:
                        for r in self._previous_results:
                            if "id" in r:
                                self._previous_results_ids.add(r["id"])
        except json.decoder.JSONDecodeError:
            logger.error(
                red("Impossible to decode {}. Consider removing the file".format(filename))
            )

    def write_results_to_hide(self):
        if not self._results_to_hide:
            return
        filename = self._previous_results_filename
        with open(filename, "w", encoding="utf8") as f:
            results = self._results_to_hide + self._previous_results
            json.dump(results, f)

    def save_results_to_hide(self, results: List[Dict]):
        self._results_to_hide += results

    def add_path_to_filter(self, path: str):
        """
        Add path to filter
        Path are used through direct comparison (no regex)
        """
        self._paths_to_filter.add(path)

    # endregion
    ###################################################################################
    ###################################################################################
    # region Crytic compile
    ###################################################################################
    ###################################################################################

    @property
    def crytic_compile(self) -> Optional[CryticCompile]:
        return self._crytic_compile

    # endregion
    ###################################################################################
    ###################################################################################
    # region Format
    ###################################################################################
    ###################################################################################

    @property
    def generate_patches(self) -> bool:
        return self._generate_patches

    @generate_patches.setter
    def generate_patches(self, p: bool):
        self._generate_patches = p

    # endregion
    ###################################################################################
    ###################################################################################
    # region Internals
    ###################################################################################
    ###################################################################################

    @property
    def contract_name_collisions(self) -> Dict:
        return self._contract_name_collisions

    @property
    def contracts_with_missing_inheritance(self) -> Set:
        return self._contract_with_missing_inheritance

    @property
    def disallow_partial(self) -> bool:
        """
        Return true if partial analyses are disallowed
        For example, codebase with duplicate names will lead to partial analyses

        :return:
        """
        return self._disallow_partial

    @property
    def skip_assembly(self) -> bool:
        return self._skip_assembly

    @property
    def show_ignore_findings(self) -> bool:
        return self.show_ignore_findings

    # endregion
    ###################################################################################
    ###################################################################################
    # region Storage Layouts
    ###################################################################################
    ###################################################################################

    def compute_storage_layout(self):
        for contract in self.contracts_derived:
            self._storage_layouts[contract.name] = {}

            slot = 0
            offset = 0
            for var in contract.state_variables_ordered:
                if var.is_constant:
                    continue

                size, new_slot = var.type.storage_size

                if new_slot:
                    if offset > 0:
                        slot += 1
                        offset = 0
                elif size + offset > 32:
                    slot += 1
                    offset = 0

                self._storage_layouts[contract.name][var.canonical_name] = (
                    slot,
                    offset,
                )
                if new_slot:
                    slot += math.ceil(size / 32)
                else:
                    offset += size

    def storage_layout_of(self, contract, var) -> Tuple[int, int]:
        return self._storage_layouts[contract.name][var.canonical_name]

    # endregion
