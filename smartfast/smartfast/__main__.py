#!/usr/bin/env python3

import argparse
import cProfile
import glob
import inspect
import json
import random
import logging
import os
import pstats
import sys
import traceback
import copy
import time
from collections import OrderedDict
from smartfast.utils.colors import green, yellow, red
from typing import Optional

from pkg_resources import iter_entry_points, require

from crytic_compile import cryticparser
from crytic_compile.platform.standard import generate_standard_export
from crytic_compile import compile_all, is_supported

from smartfast.detectors import all_detectors
from smartfast.detectors.abstract_detector import AbstractDetector, DetectorClassification
from smartfast.printers import all_printers
from smartfast.printers.abstract_printer import AbstractPrinter
from smartfast.smartfast import Smartfast
from smartfast.utils.output import output_to_json, output_to_zip, ZIP_TYPES_ACCEPTED
from smartfast.utils.output_capture import StandardOutputCapture
from smartfast.utils.colors import red, blue, set_colorization_enabled
from smartfast.utils.command_line import (
    output_detectors,
    output_results_to_markdown,
    output_detectors_json,
    output_printers,
    output_printers_json,
    output_to_markdown,
    output_wiki,
    defaults_flag_in_config,
    read_config_file,
    JSON_OUTPUT_TYPES,
    DEFAULT_JSON_OUTPUT_TYPES,
)
from smartfast.exceptions import SmartfastException
from smartfast.xmlanalysis import Xmlanalysis
from smartfast.report_english import ReportEnglish
from smartfast.detectors.abstract_detector import DetectorClassification

logging.basicConfig()
logger = logging.getLogger("Smartfast")
logger_detector = logging.getLogger("Detectors")

classification_txt_colors = {
    'Informational': green,
    'Optimization': green,
    'Low': green,
    'Medium': yellow,
    'High': red
}

###################################################################################
###################################################################################
# region Process functions
###################################################################################
###################################################################################


def process_single(target, args, detector_classes, printer_classes):
    """
    The core high-level code for running Smartfast static analysis.

    Returns:
        list(result), int: Result list and number of contracts analyzed
    """
    ast = "--ast-compact-json"
    if args.legacy_ast:
        ast = "--ast-json"
    smartfast = Smartfast(target, ast_format=ast, **vars(args))

    return _process(smartfast, detector_classes, printer_classes)

def process_single_mixed(target, args, detector_classes, printer_classes, xmlresults):
    """
    The core high-level code for running Smartfast static analysis.

    Returns:
        list(result), int: Result list and number of contracts analyzed
    """
    ast = '--ast-compact-json'
    if args.legacy_ast:
        ast = '--ast-json'
    smartfast = Smartfast(target,
                      ast_format=ast,
                      **vars(args))

    return _process_mixed(smartfast, detector_classes, printer_classes, xmlresults)

def process_all(target, args, detector_classes, printer_classes):
    compilations = None
    try:
        compilations = compile_all(target, **vars(args))
    except:
        print("Unable to compile, only xml parsing......")
        return None,None,None,0
    smartfast_instances = []
    results_detectors = []
    results_printers = []
    analyzed_contracts_count = 0
    for compilation in compilations:
        (
            smartfast,
            current_results_detectors,
            current_results_printers,
            current_analyzed_count,
        ) = process_single(compilation, args, detector_classes, printer_classes)
        results_detectors.extend(current_results_detectors)
        results_printers.extend(current_results_printers)
        smartfast_instances.append(smartfast)
        analyzed_contracts_count += current_analyzed_count
    return (
        smartfast_instances,
        results_detectors,
        results_printers,
        analyzed_contracts_count,
    )

def process_all_mixed(target, args, detector_classes, printer_classes, xmlresults):
    compilations = None
    try:
        compilations = compile_all(target, **vars(args))
    except:
        print("Unable to compile, only xml parsing......")
        return None,None,None,0
    # except Exception:
    #     output_error = traceback.format_exc()
    #     print(output_error)
    #     print("Unable to compile, only xml parsing......")
    #     return None,None,None,0
    smartfast_instances = []
    results_detectors = []
    results_printers = []
    analyzed_contracts_count = 0
    for compilation in compilations:
        (smartfast, current_results_detectors, current_results_printers, current_analyzed_count) = process_single_mixed(
            compilation, args, detector_classes, printer_classes, xmlresults)
        results_detectors.extend(current_results_detectors)
        results_printers.extend(current_results_printers)
        smartfast_instances.append(smartfast)
        analyzed_contracts_count += current_analyzed_count
    return smartfast_instances, results_detectors, results_printers, analyzed_contracts_count

def _process(smartfast, detector_classes, printer_classes):
    for detector_cls in detector_classes:
        smartfast.register_detector(detector_cls)

    for printer_cls in printer_classes:
        smartfast.register_printer(printer_cls)

    analyzed_contracts_count = len(smartfast.contracts)

    results_detectors = []
    results_printers = []

    if not printer_classes:
        detector_results = smartfast.run_detectors()
        detector_results = [x for x in detector_results if x]  # remove empty results
        detector_results = [item for sublist in detector_results for item in sublist]  # flatten
        results_detectors.extend(detector_results)

    else:
        printer_results = smartfast.run_printers()
        printer_results = [x for x in printer_results if x]  # remove empty results
        results_printers.extend(printer_results)

    return smartfast, results_detectors, results_printers, analyzed_contracts_count

def _process_mixed(smartfast, detector_classes, printer_classes, xmlresults):
    for detector_cls in detector_classes:
        smartfast.register_detector(detector_cls)

    for printer_cls in printer_classes:
        smartfast.register_printer(printer_cls)

    analyzed_contracts_count = len(smartfast.contracts)

    results_detectors = []
    results_printers = []

    if not printer_classes:
        detector_results = smartfast.run_detectors_mixed(xmlresults)
        detector_results = [x for x in detector_results if x]  # remove empty results
        detector_results = [item for sublist in detector_results for item in sublist]  # flatten
        results_detectors.extend(detector_results)
    else:
        printer_results = smartfast.run_printers()
        printer_results = [x for x in printer_results if x]  # remove empty results
        results_printers.extend(printer_results)

    return smartfast, results_detectors, results_printers, analyzed_contracts_count

def process_from_asts(filenames, args, detector_classes, printer_classes):
    all_contracts = []

    for filename in filenames:
        with open(filename, encoding="utf8") as file_open:
            contract_loaded = json.load(file_open)
            all_contracts.append(contract_loaded["ast"])

    return process_single(all_contracts, args, detector_classes, printer_classes)


# endregion
###################################################################################
###################################################################################
# region Exit
###################################################################################
###################################################################################


def exit(results):
    if not results:
        sys.exit(0)
    sys.exit(2)

def getseverity(impact, confidence):
    severity = None
    if (impact == 'High') and (confidence in ['exactly', 'probably']):
        severity = 'High'
    elif ((impact == 'High') and (confidence == 'possibly')) or ((impact == 'Medium') and (confidence in ['exactly', 'probably'])):
        severity = 'Medium'
    elif ((impact == 'Medium') and (confidence == 'possibly')) or ((impact == 'Low') and (confidence in ['exactly', 'probably', 'possibly'])):
        severity = 'Low'
    elif (impact == 'Informational') and (confidence in ['exactly', 'probably', 'possibly']):
        severity = 'Informational'
    elif (impact == 'Optimization') and (confidence in ['exactly', 'probably', 'possibly']):
        severity = 'Optimization'
    return severity

# endregion
###################################################################################
###################################################################################
# region Detectors and printers
###################################################################################
###################################################################################


def get_detectors_and_printers():
    """
    NOTE: This contains just a few detectors and printers that we made public.
    """

    detectors = [getattr(all_detectors, name) for name in dir(all_detectors)]
    detectors = [d for d in detectors if inspect.isclass(d) and issubclass(d, AbstractDetector)]

    printers = [getattr(all_printers, name) for name in dir(all_printers)]
    printers = [p for p in printers if inspect.isclass(p) and issubclass(p, AbstractPrinter)]

    # Handle plugins!
    for entry_point in iter_entry_points(group="smartfast_analyzer.plugin", name=None):
        make_plugin = entry_point.load()

        plugin_detectors, plugin_printers = make_plugin()

        detector = None
        if not all(issubclass(detector, AbstractDetector) for detector in plugin_detectors):
            raise Exception(
                "Error when loading plugin %s, %r is not a detector" % (entry_point, detector)
            )
        printer = None
        if not all(issubclass(printer, AbstractPrinter) for printer in plugin_printers):
            raise Exception(
                "Error when loading plugin %s, %r is not a printer" % (entry_point, printer)
            )

        # We convert those to lists in case someone returns a tuple
        detectors += list(plugin_detectors)
        printers += list(plugin_printers)

    return detectors, printers


# pylint: disable=too-many-branches
def choose_detectors(args, all_detector_classes):
    # If detectors are specified, run only these ones

    detectors_to_run = []
    detectors = {d.ARGUMENT: d for d in all_detector_classes}

    if args.detectors_to_run == "all":
        detectors_to_run = all_detector_classes
        if args.detectors_to_exclude:
            detectors_excluded = args.detectors_to_exclude.split(",")
            for detector in detectors:
                if detector in detectors_excluded:
                    detectors_to_run.remove(detectors[detector])
    else:
        for detector in args.detectors_to_run.split(","):
            if detector in detectors:
                detectors_to_run.append(detectors[detector])
            else:
                raise Exception("Error: {} is not a detector".format(detector))
        detectors_to_run = sorted(detectors_to_run, key=lambda x: x.IMPACT)
        return detectors_to_run

    if args.exclude_optimization:
        detectors_to_run = [
            d for d in detectors_to_run if d.IMPACT != DetectorClassification.OPTIMIZATION
        ]

    if args.exclude_informational:
        detectors_to_run = [
            d for d in detectors_to_run if d.IMPACT != DetectorClassification.INFORMATIONAL
        ]
    if args.exclude_low:
        detectors_to_run = [d for d in detectors_to_run if d.IMPACT != DetectorClassification.LOW]
    if args.exclude_medium:
        detectors_to_run = [
            d for d in detectors_to_run if d.IMPACT != DetectorClassification.MEDIUM
        ]
    if args.exclude_high:
        detectors_to_run = [d for d in detectors_to_run if d.IMPACT != DetectorClassification.HIGH]
    if args.detectors_to_exclude:
        detectors_to_run = [
            d for d in detectors_to_run if d.ARGUMENT not in args.detectors_to_exclude
        ]

    detectors_to_run = sorted(detectors_to_run, key=lambda x: x.IMPACT)

    return detectors_to_run


def choose_printers(args, all_printer_classes):
    printers_to_run = []

    # disable default printer
    if args.printers_to_run is None:
        return []

    if args.printers_to_run == "all":
        return all_printer_classes

    printers = {p.ARGUMENT: p for p in all_printer_classes}
    for printer in args.printers_to_run.split(","):
        if printer in printers:
            printers_to_run.append(printers[printer])
        else:
            raise Exception("Error: {} is not a printer".format(printer))
    return printers_to_run


# endregion
###################################################################################
###################################################################################
# region Command line parsing
###################################################################################
###################################################################################


def parse_filter_paths(args):
    if args.filter_paths:
        return args.filter_paths.split(",")
    return []


def parse_args(detector_classes, printer_classes):  # pylint: disable=too-many-statements
    parser = argparse.ArgumentParser(
        description="Smartfast. For usage information, see https://github.com/smartfast/wiki/Usage",
        usage="smartfast.py contract.sol [flag]",
    )

    parser.add_argument("filename", help="contract.sol")

    cryticparser.init(parser)

    parser.add_argument(
        "--version",
        help="displays the current version",
        version=require("smartfast-analyzer")[0].version,
        action="version",
    )

    group_detector = parser.add_argument_group("Detectors")
    group_printer = parser.add_argument_group("Printers")
    group_misc = parser.add_argument_group("Additional options")

    group_detector.add_argument(
        "--detect",
        help="Comma-separated list of detectors, defaults to all, "
        "available detectors: {}".format(", ".join(d.ARGUMENT for d in detector_classes)),
        action="store",
        dest="detectors_to_run",
        default=defaults_flag_in_config["detectors_to_run"],
    )

    group_printer.add_argument(
        "--print",
        help="Comma-separated list fo contract information printers, "
        "available printers: {}".format(", ".join(d.ARGUMENT for d in printer_classes)),
        action="store",
        dest="printers_to_run",
        default=defaults_flag_in_config["printers_to_run"],
    )

    group_detector.add_argument(
        "--list-detectors",
        help="List available detectors",
        action=ListDetectors,
        nargs=0,
        default=False,
    )

    group_printer.add_argument(
        "--list-printers",
        help="List available printers",
        action=ListPrinters,
        nargs=0,
        default=False,
    )

    group_detector.add_argument(
        "--exclude",
        help="Comma-separated list of detectors that should be excluded",
        action="store",
        dest="detectors_to_exclude",
        default=defaults_flag_in_config["detectors_to_exclude"],
    )

    group_detector.add_argument(
        "--exclude-dependencies",
        help="Exclude results that are only related to dependencies",
        action="store_true",
        default=defaults_flag_in_config["exclude_dependencies"],
    )

    group_detector.add_argument(
        "--exclude-optimization",
        help="Exclude optimization analyses",
        action="store_true",
        default=defaults_flag_in_config["exclude_optimization"],
    )

    group_detector.add_argument(
        "--exclude-informational",
        help="Exclude informational impact analyses",
        action="store_true",
        default=defaults_flag_in_config["exclude_informational"],
    )

    group_detector.add_argument(
        "--exclude-low",
        help="Exclude low impact analyses",
        action="store_true",
        default=defaults_flag_in_config["exclude_low"],
    )

    group_detector.add_argument(
        "--exclude-medium",
        help="Exclude medium impact analyses",
        action="store_true",
        default=defaults_flag_in_config["exclude_medium"],
    )

    group_detector.add_argument(
        "--exclude-high",
        help="Exclude high impact analyses",
        action="store_true",
        default=defaults_flag_in_config["exclude_high"],
    )

    group_detector.add_argument(
        "--show-ignored-findings",
        help="Show all the findings",
        action="store_true",
        default=defaults_flag_in_config["show_ignored_findings"],
    )

    group_misc.add_argument(
        "--json",
        help='Export the results as a JSON file ("--json -" to export to stdout)',
        action="store",
        default=defaults_flag_in_config["json"],
    )

    group_misc.add_argument(
        "--json-types",
        help="Comma-separated list of result types to output to JSON, defaults to "
        + f'{",".join(output_type for output_type in DEFAULT_JSON_OUTPUT_TYPES)}. '
        + f'Available types: {",".join(output_type for output_type in JSON_OUTPUT_TYPES)}',
        action="store",
        default=defaults_flag_in_config["json-types"],
    )

    group_misc.add_argument(
        "--zip",
        help="Export the results as a zipped JSON file",
        action="store",
        default=defaults_flag_in_config["zip"],
    )

    group_misc.add_argument(
        "--zip-type",
        help=f'Zip compression type. One of {",".join(ZIP_TYPES_ACCEPTED.keys())}. Default lzma',
        action="store",
        default=defaults_flag_in_config["zip_type"],
    )

    group_misc.add_argument(
        "--markdown-root",
        help="URL for markdown generation",
        action="store",
        default="",
    )

    group_misc.add_argument(
        "--disable-color",
        help="Disable output colorization",
        action="store_true",
        default=defaults_flag_in_config["disable_color"],
    )

    group_misc.add_argument(
        "--filter-paths",
        help="Comma-separated list of paths for which results will be excluded",
        action="store",
        dest="filter_paths",
        default=defaults_flag_in_config["filter_paths"],
    )

    group_misc.add_argument(
        "--triage-mode",
        help="Run triage mode (save results in smartfast.db.json)",
        action="store_true",
        dest="triage_mode",
        default=False,
    )

    group_misc.add_argument(
        "--config-file",
        help="Provide a config file (default: smartfast.config.json)",
        action="store",
        dest="config_file",
        default="smartfast.config.json",
    )

    group_misc.add_argument(
        "--solc-ast",
        help="Provide the contract as a json AST",
        action="store_true",
        default=False,
    )

    group_misc.add_argument(
        "--generate-patches",
        help="Generate patches (json output only)",
        action="store_true",
        default=False,
    )

    group_misc.add_argument('--report',
                            help='Export the audit report as a pdf file ("--report -" to export to stdout)',
                            action='store',
                            default=defaults_flag_in_config['report'])
                        
    group_misc.add_argument('--report-main',
                            help='Export the main audit report as a pdf file ("--report-main -" to export to main stdout)',
                            action='store',
                            default=defaults_flag_in_config['report_main'])

    # group_misc.add_argument('--report-chinese',
    #                         help='Export the audit report as a pdf file ("--report-chinese -" to export to stdout)',
    #                         action='store',
    #                         default=defaults_flag_in_config['report_chinese'])
                        
    # group_misc.add_argument('--report-main-chinese',
    #                         help='Export the main audit report as a pdf file ("--report-main-chinese -" to export to main stdout)',
    #                         action='store',
    #                         default=defaults_flag_in_config['report_main_chinese'])

    # debugger command
    parser.add_argument("--debug", help=argparse.SUPPRESS, action="store_true", default=False)

    parser.add_argument("--markdown", help=argparse.SUPPRESS, action=OutputMarkdown, default=False)

    group_misc.add_argument(
        "--checklist", help=argparse.SUPPRESS, action="store_true", default=False
    )

    parser.add_argument(
        "--wiki-detectors", help=argparse.SUPPRESS, action=OutputWiki, default=False
    )

    parser.add_argument(
        "--list-detectors-json",
        help=argparse.SUPPRESS,
        action=ListDetectorsJson,
        nargs=0,
        default=False,
    )

    parser.add_argument(
        "--legacy-ast",
        help=argparse.SUPPRESS,
        action="store_true",
        default=defaults_flag_in_config["legacy_ast"],
    )

    parser.add_argument(
        "--skip-assembly",
        help=argparse.SUPPRESS,
        action="store_true",
        default=defaults_flag_in_config["skip_assembly"],
    )

    parser.add_argument(
        "--ignore-return-value",
        help=argparse.SUPPRESS,
        action="store_true",
        default=defaults_flag_in_config["ignore_return_value"],
    )

    parser.add_argument(
        "--perf", help=argparse.SUPPRESS, action="store_true", default=False,
    )

    # if the json is splitted in different files
    parser.add_argument("--splitted", help=argparse.SUPPRESS, action="store_true", default=False)

    # Disable the throw/catch on partial analyses
    parser.add_argument(
        "--disallow-partial", help=argparse.SUPPRESS, action="store_true", default=False
    )

    if len(sys.argv) == 1:
        parser.print_help(sys.stderr)
        sys.exit(1)

    args = parser.parse_args()
    read_config_file(args)

    args.filter_paths = parse_filter_paths(args)

    # Verify our json-type output is valid
    args.json_types = set(args.json_types.split(","))
    for json_type in args.json_types:
        if json_type not in JSON_OUTPUT_TYPES:
            raise Exception(f'Error: "{json_type}" is not a valid JSON result output type.')

    return args


class ListDetectors(argparse.Action):  # pylint: disable=too-few-public-methods
    def __call__(self, parser, *args, **kwargs):  # pylint: disable=signature-differs
        detectors, _ = get_detectors_and_printers()

        class Detector_tmp:
            def  __init__(self, ARGUMENT, HELP, IMPACT, CONFIDENCE):
                self.ARGUMENT = ARGUMENT
                self.HELP = HELP
                self.IMPACT = IMPACT
                self.CONFIDENCE = CONFIDENCE

        detector_xml = {'names-reused': ['High', 'exactly', 'Check contract name reuse'], 'multiple-constructors': ['High', 'exactly', 'Multiple constructors in a contract'], 'visibility': ['High/Informational', 'exactly', 'Check visibility level error'], 'redundant-fallback': ['High/Optimization', 'exactly', 'Check for redundant fallback functions'], 'hardcoded': ['Informational', 'probably', 'Check the legitimacy of the address'], 'length-manipulation': ['Informational', 'exactly', 'Unsafe operation to check array length'], 'delete-dynamic-arrays': ['Informational', 'exactly', 'The deletion of the dynamic storage array'], 'erc20-throw': ['Informational', 'exactly', 'ERC20 throws an exception'], 'msgvalue-equals-zero': ['Informational', 'exactly', 'The judgment of msg.value and zero'], 'overpowered-role': ['Informational', 'probably', 'The permissions are too concentrated'], 'private-not-hidedata': ['Informational', 'possibly', 'Check the use of private visibility'], 'safemath': ['Informational', 'possibly', 'Check the use of SafeMath'], 'upgrade-050': ['Informational', 'exactly', 'Code for Solidity 0.5.x upgrade'], 'assembly': ['Informational', 'exactly', 'Unsafe use of assembly'], 'incorrect-blockhash': ['Low', 'probably', 'Incorrect use of Blockhash function'], 'assemblycall-rewrite': ['Low', 'probably', 'Assemblycall covers the input'], 'extcodesize-invoke': ['Low', 'probably', 'Check Extcodesize call'], 'constructor-return': ['Medium', 'exactly', 'The use of return in the constructor'], 'erc20-approve': ['Medium', 'probably', 'ERC-20 advance attack (TOD)'], 'costly-loop': ['Medium', 'possibly', 'Check for too expensive loops'], 'incorrect-signature': ['Medium', 'exactly', 'Check for incorrect function signatures'], 'typographical-error': ['Medium', 'probably', 'Check for writing errors (=+)'], 'shift-parameter-mixup': ['Medium', 'possibly', 'Check reversible shift operation'], 'array-instead-bytes': ['Optimization', 'exactly', 'The byte array can be replaced with bytes'], 'extra-gas-inloops': ['Optimization', 'exactly', 'Check for additional gas consumption'], 'revert-require': ['Optimization', 'exactly', 'Check Revert in if operation'], 'send-transfer': ['Optimization', 'exactly', 'Check Transfe to replace Send'], 'return-struct': ['Optimization', 'exactly', 'Multiple return values (struct)'], 'code-no-effects': ['Optimization', 'exactly', 'Check for invalid codes']}

        for ARGUMENT, detector_val in detector_xml.items():
            IMPACT = detector_val[0]
            CONFIDENCE = detector_val[1]
            if 'High' in IMPACT:
                IMPACT =  DetectorClassification.HIGH
            elif 'Medium' in IMPACT:
                IMPACT =  DetectorClassification.MEDIUM
            elif 'Low' in IMPACT:
                IMPACT =  DetectorClassification.LOW
            elif 'Informational' in IMPACT:
                IMPACT =  DetectorClassification.INFORMATIONAL
            else:
                IMPACT =  DetectorClassification.OPTIMIZATION

            if 'exactly' in CONFIDENCE:
                CONFIDENCE =  DetectorClassification.EXACTLY
            elif 'probably' in CONFIDENCE:
                CONFIDENCE =  DetectorClassification.PROBABLY
            else:
                CONFIDENCE =  DetectorClassification.POSSIBLY

            detector_class_val = Detector_tmp(ARGUMENT, detector_val[2], IMPACT, CONFIDENCE)
            detectors.append(detector_class_val)
            del detector_class_val

        output_detectors(detectors, detector_xml)
        parser.exit()


class ListDetectorsJson(argparse.Action):  # pylint: disable=too-few-public-methods
    def __call__(self, parser, *args, **kwargs):  # pylint: disable=signature-differs
        detectors, _ = get_detectors_and_printers()
        detector_types_json = output_detectors_json(detectors)
        print(json.dumps(detector_types_json))
        parser.exit()


class ListPrinters(argparse.Action):  # pylint: disable=too-few-public-methods
    def __call__(self, parser, *args, **kwargs):  # pylint: disable=signature-differs
        _, printers = get_detectors_and_printers()
        output_printers(printers)
        parser.exit()


class OutputMarkdown(argparse.Action):  # pylint: disable=too-few-public-methods
    def __call__(self, parser, args, values, option_string=None):
        detectors, printers = get_detectors_and_printers()
        output_to_markdown(detectors, printers, values)
        parser.exit()


class OutputWiki(argparse.Action):  # pylint: disable=too-few-public-methods
    def __call__(self, parser, args, values, option_string=None):
        detectors, _ = get_detectors_and_printers()
        output_wiki(detectors, values)
        parser.exit()


# endregion
###################################################################################
###################################################################################
# region CustomFormatter
###################################################################################
###################################################################################


class FormatterCryticCompile(logging.Formatter):
    def format(self, record):
        # for i, msg in enumerate(record.msg):
        if record.msg.startswith("Compilation warnings/errors on "):
            txt = record.args[1]
            txt = txt.split("\n")
            txt = [red(x) if "Error" in x else x for x in txt]
            txt = "\n".join(txt)
            record.args = (record.args[0], txt)
        return super().format(record)


# endregion
###################################################################################
###################################################################################
# region Main
###################################################################################
###################################################################################

def get_linenum_from_startcharnum(lines_chars, start):
    line_num = 0
    char_num = 0

    for i in range(len(lines_chars)):
        if lines_chars[i] >= start:
            line_num = i + 1
            if i == 0:
                char_num = start + 1
            else:
                char_num = start - lines_chars[i-1] + 1
            break
    
    return line_num, char_num


def main():
    # Codebase with complex domninators can lead to a lot of SSA recursive call
    sys.setrecursionlimit(1500)

    detectors, printers = get_detectors_and_printers()

    main_impl(all_detector_classes=detectors, all_printer_classes=printers)


# pylint: disable=too-many-statements,too-many-branches,too-many-locals
def main_impl(all_detector_classes, all_printer_classes):
    """
    :param all_detector_classes: A list of all detectors that can be included/excluded.
    :param all_printer_classes: A list of all printers that can be included.
    """
    # Set logger of Smartfast to info, to catch warnings related to the arg parsing
    logger.setLevel(logging.INFO)
    args = parse_args(all_detector_classes, all_printer_classes)

    cp: Optional[cProfile.Profile] = None
    if args.perf:
        cp = cProfile.Profile()
        cp.enable()

    # Set colorization option
    set_colorization_enabled(not args.disable_color)

    # Define some variables for potential JSON output
    json_results = {}
    output_error = None
    outputting_json = args.json is not None
    outputting_json_stdout = args.json == "-"
    outputting_report = args.report is not None
    outputting_report_main = args.report_main is not None
    # outputting_report_chinese = args.report_chinese is not None
    # outputting_report_main_chinese = args.report_main_chinese is not None
    outputting_zip = args.zip is not None
    if args.zip_type not in ZIP_TYPES_ACCEPTED.keys():
        to_log = f'Zip type not accepted, it must be one of {",".join(ZIP_TYPES_ACCEPTED.keys())}'
        logger.error(to_log)

    # If we are outputting JSON, capture all standard output. If we are outputting to stdout, we block typical stdout
    # output.
    if outputting_json:
        StandardOutputCapture.enable(outputting_json_stdout)

    printer_classes = choose_printers(args, all_printer_classes)
    detector_classes = choose_detectors(args, all_detector_classes)

    default_log = logging.INFO if not args.debug else logging.DEBUG
    # default_log = logging.WARNING if not args.debug else logging.DEBUG

    for (l_name, l_level) in [
        ("Smartfast", default_log),
        ("Contract", default_log),
        ("Function", default_log),
        ("Node", default_log),
        ("Parsing", default_log),
        ("Detectors", default_log),
        ("FunctionSolc", default_log),
        ("ExpressionParsing", default_log),
        ("TypeParsing", default_log),
        ("SSA_Conversion", default_log),
        ("Printers", default_log),
        # ('CryticCompile', default_log)
    ]:
        logger_level = logging.getLogger(l_name)
        logger_level.setLevel(l_level)

    console_handler = logging.StreamHandler()
    console_handler.setLevel(logging.INFO)

    console_handler.setFormatter(FormatterCryticCompile())

    #crytic_compile output
    # crytic_compile_error = logging.getLogger(("CryticCompile"))
    # crytic_compile_error.addHandler(console_handler)
    # crytic_compile_error.propagate = False
    # crytic_compile_error.setLevel(logging.INFO)

    results_detectors = []
    results_printers = []
    xml_results = {}
    time_start = time.localtime()
    time_begin = time.time()
    audit_time = 0
    auditid = ""
    auditcontent = ""
    contracts_names = []
    filename = ""
    if outputting_report or outputting_report_main:
        auditid = auditid + time.strftime("%m%d%H%M%S", time_start)
        auditid = auditid + str(random.randint(1000,9999))
        # print(auditid)
    try:
        filename = args.filename

        # Determine if we are handling ast from solc
        if args.solc_ast or (filename.endswith(".json") and not is_supported(filename)):
            globbed_filenames = glob.glob(filename, recursive=True)
            filenames = glob.glob(os.path.join(filename, "*.json"))
            if not filenames:
                filenames = globbed_filenames
            number_contracts = 0

            smartfast_instances = []
            if args.splitted:
                (
                    smartfast_instance,
                    results_detectors,
                    results_printers,
                    number_contracts,
                ) = process_from_asts(filenames, args, detector_classes, printer_classes)
                smartfast_instances.append(smartfast_instance)
            else:
                for filename in filenames:
                    (
                        smartfast_instance,
                        results_detectors_tmp,
                        results_printers_tmp,
                        number_contracts_tmp,
                    ) = process_single(filename, args, detector_classes, printer_classes)
                    number_contracts += number_contracts_tmp
                    results_detectors += results_detectors_tmp
                    results_printers += results_printers_tmp
                    smartfast_instances.append(smartfast_instance)

        # Rely on CryticCompile to discern the underlying type of compilations.
        else:
            dict_val = OrderedDict()
            xmlanalysis = Xmlanalysis()
            linklists = xmlanalysis._analysispath(filename)
            for i in range(linklists.size()):
                dict_val = OrderedDict()
                dict_val['elements'] = [{'source_mapping':{'lines': [int(linklists.get(i).get('context_ling'))], 'starting_column': int(linklists.get(i).get('starting_column'))}}]
                dict_val['impact'] = str(linklists.get(i).get('severity'))
                argument_val = str(linklists.get(i).get('argument'))
                dict_val['check'] = argument_val
                dict_val['description'] = str(linklists.get(i).get('description_val'))
                dict_val['confidence'] = str(linklists.get(i).get('confidence'))
                # dict_val['text'] = str(linklists.get(i).get('text'))
                if argument_val not in xml_results.keys():
                    xml_results[argument_val] = []
                xml_results[argument_val].append(dict_val)
            xmlanalysis._shutdownjvm()
            # print(xml_results)#hashmap
            # print(type(xml_results[0]))
            (
                smartfast_instances,
                results_detectors,
                results_printers,
                number_contracts,
            ) = process_all_mixed(filename, args, detector_classes, printer_classes, xml_results)
            if results_detectors == None:
                results_detectors = []
                for k,v in xml_results.items():
                    results_detectors.extend(v)
                    if logger_detector:
                        idx = 0
                        nextreport = v.copy()              
                        while True: 
                            info = '\n'
                            nowreport = nextreport.copy()
                            nextreport = []
                            impact = nowreport[0]['impact']
                            check = nowreport[0]['check']
                            confidence = nowreport[0]['confidence']
                            for idy,result in enumerate(nowreport):
                                # print(result)
                                if result['impact'] == impact:
                                    if args.triage_mode:
                                        info += '{}: '.format(idx)
                                        idx = idx + 1
                                    info += result['description']
                                else:
                                    nextreport.append(result)
                            if not nextreport:
                                info += 'The above is the result of <{}>, the difficulty of detection is |{}|, and the confidence is [{}].'.format(check, impact, confidence)
                                logger_detector.info(classification_txt_colors[impact](info))
                                # print(info)
                                break
                            info += 'The above is the result of <{}>, the difficulty of detection is |{}|, and the confidence is [{}].'.format(check, impact, confidence)
                            logger_detector.info(classification_txt_colors[impact](info))
                            # print(info)
                            # print("---:"+str(nextreport))
                detector_classes = []

                # results_detectors = xml_results
            # print(results_detectors)
            # for i in range(len(results_detectors)):
            #     print(results_detectors[i])
            #     print("------")

        # print(results_detectors)

        # Determine if we are outputting JSON
        if outputting_json or outputting_zip:
            # Add our compilation information to JSON
            if "compilations" in args.json_types:
                compilation_results = []
                for smartfast_instance in smartfast_instances:
                    compilation_results.append(
                        generate_standard_export(smartfast_instance.crytic_compile)
                    )
                json_results["compilations"] = compilation_results

            # Add our detector results to JSON if desired.
            if results_detectors and "detectors" in args.json_types:
                json_results["detectors"] = results_detectors

            # Add our printer results to JSON if desired.
            if results_printers and "printers" in args.json_types:
                json_results["printers"] = results_printers

            # Add our detector types to JSON
            if "list-detectors" in args.json_types:
                detectors, _ = get_detectors_and_printers()
                json_results["list-detectors"] = output_detectors_json(detectors)

            # Add our detector types to JSON
            if "list-printers" in args.json_types:
                _, printers = get_detectors_and_printers()
                json_results["list-printers"] = output_printers_json(printers)

        # Output our results to markdown if we wish to compile a checklist.
        if args.checklist:
            output_results_to_markdown(results_detectors)

        # Dont print the number of result for printers
        if number_contracts == 0 and smartfast_instances:
            logger.warning(red("No contract was analyzed"))
            print("No contract was analyzed")
        if printer_classes:
            logger.info("%s analyzed (%d contracts)", filename, number_contracts)
            print("{} analyzed ({} contracts)".format(filename, number_contracts))
        else:
            logger.info('%s analyzed (%d contracts with %d detectors), %d result(s) found', filename,
                        number_contracts, len(detector_classes)+29, len(results_detectors))
            print('{} analyzed ({} contracts with {} detectors), {} result(s) found'.format(filename,
                        number_contracts, len(detector_classes)+29, len(results_detectors)))

        audit_time = int((time.time() - time_begin)*1000)

        # logger.info(
        #     blue(
        #         "Use https://crytic.io/ to get access to additional detectors and Github integration"
        #     )
        # )
        if args.ignore_return_value:
            return
        if outputting_report or outputting_report_main:
            if smartfast_instances:
                for instance in smartfast_instances:
                    for contract_val in instance.contracts:
                        # print(contract_val.name)
                        if contract_val.name not in contracts_names:
                            contracts_names.append(contract_val.name)

    except SmartfastException as smartfast_exception:
        output_error = str(smartfast_exception)
        traceback.print_exc()
        logging.error(red("Error:"))
        logging.error(red(output_error))
        # logging.error("Please report an issue to https://github.com/SmartContractTools/SmartFast/issues")

    except Exception:  # pylint: disable=broad-except
        output_error = traceback.format_exc()
        logging.error(traceback.print_exc())
        logging.error(f"Error in {args.filename}")  # pylint: disable=logging-fstring-interpolation
        logging.error(output_error)

    # If we are outputting JSON, capture the redirected output and disable the redirect to output the final JSON.
    if outputting_json:
        if "console" in args.json_types:
            json_results["console"] = {
                "stdout": StandardOutputCapture.get_stdout_output(),
                "stderr": StandardOutputCapture.get_stderr_output(),
            }
        StandardOutputCapture.disable()
        output_to_json(None if outputting_json_stdout else args.json, output_error, json_results)

    if outputting_zip:
        output_to_zip(args.zip, output_error, json_results, args.zip_type)

    # holeloops = []
    
    #filename
    #time_start
    #auditcontent
    #contracts_names
    try:
        if os.path.exists(filename):
            file = open(filename,encoding='utf-8')
            lines = file.readlines()
            if lines:
                #lines numbers
                lines_chars = []
                for i in range(len(lines)):
                    if i == 0:
                        lines_chars.append(len(lines[i]))
                    else:
                        lines_chars.append(lines_chars[i-1]+len(lines[i]))
                
                linesnumber = []
                for element in results_detectors:
                    if 'elements' in element and element['elements']:
                        pasteif = False
                        for elements_val in element['elements']:
                            if 'type' in elements_val and elements_val['type'] == "variable":
                                if 'source_mapping' in elements_val:
                                    if 'lines' in elements_val['source_mapping']:
                                        if elements_val['source_mapping']['lines']:
                                            content_val = lines[elements_val['source_mapping']['lines'][0]-1]
                                            # if element['check'] not in holeloop:
                                            #     holeloop[element['check']] = []
                                            # holeloop[element['check']].append(elements_val['source_mapping']['lines'][0])
                                            if (elements_val['source_mapping']['lines'][0]-1) in linesnumber:
                                                lines[elements_val['source_mapping']['lines'][0]-1] = content_val[:len(content_val)-1] + "、" + element['check'] + '\n'
                                            else:
                                                lines[elements_val['source_mapping']['lines'][0]-1] = content_val[:len(content_val)-1] + " //StAs //" + element['check'] + '\n'
                                                linesnumber.append(elements_val['source_mapping']['lines'][0]-1)
                                            pasteif = True
                                    elif 'start' in elements_val['source_mapping']:
                                        line_num, char_num = get_linenum_from_startcharnum(lines_chars, elements_val['source_mapping']['start'])
                                        content_val = lines[line_num-1]
                                        # if element['check'] not in holeloop:
                                        #     holeloop[element['check']] = []
                                        # holeloop[element['check']].append(line_num)
                                        if (line_num-1) in linesnumber:
                                            lines[line_num-1] = content_val[:len(content_val)-1] + "、" + element['check'] + '\n'
                                        else:
                                            lines[line_num-1] = content_val[:len(content_val)-1] + " //StAs //" + element['check'] + '\n'
                                            linesnumber.append(line_num-1)
                                        pasteif = True
                        if not pasteif:
                            for elements_val in element['elements']:
                                if 'type' in elements_val and elements_val['type'] == "node":
                                    if 'source_mapping' in elements_val:
                                        if 'lines' in elements_val['source_mapping']:
                                            if elements_val['source_mapping']['lines']:
                                                content_val = lines[elements_val['source_mapping']['lines'][0]-1]
                                                # if element['check'] not in holeloop:
                                                #     holeloop[element['check']] = []
                                                # holeloop[element['check']].append(elements_val['source_mapping']['lines'][0])
                                                if (elements_val['source_mapping']['lines'][0]-1) in linesnumber:
                                                    lines[elements_val['source_mapping']['lines'][0]-1] = content_val[:len(content_val)-1] + "、" + element['check'] + '\n'
                                                else:
                                                    lines[elements_val['source_mapping']['lines'][0]-1] = content_val[:len(content_val)-1] + " //StAs //" + element['check'] + '\n'
                                                    linesnumber.append(elements_val['source_mapping']['lines'][0]-1)
                                                pasteif = True
                                        elif 'start' in elements_val['source_mapping']:
                                            line_num, char_num = get_linenum_from_startcharnum(lines_chars, elements_val['source_mapping']['start'])
                                            content_val = lines[line_num-1]
                                            # if element['check'] not in holeloop:
                                            #     holeloop[element['check']] = []
                                            # holeloop[element['check']].append(line_num)
                                            if (line_num-1) in linesnumber:
                                                lines[line_num-1] = content_val[:len(content_val)-1] + "、" + element['check'] + '\n'
                                            else:
                                                lines[line_num-1] = content_val[:len(content_val)-1] + " //StAs //" + element['check'] + '\n'
                                                linesnumber.append(line_num-1)
                                            pasteif = True
                        if not pasteif:
                            for elements_val in element['elements']:
                                if 'type' in elements_val and elements_val['type'] == "function":
                                    if 'source_mapping' in elements_val:
                                        if 'lines' in elements_val['source_mapping']:
                                            if elements_val['source_mapping']['lines']:
                                                content_val = lines[elements_val['source_mapping']['lines'][0]-1]
                                                # if element['check'] not in holeloop:
                                                #     holeloop[element['check']] = []
                                                # holeloop[element['check']].append(elements_val['source_mapping']['lines'][0])
                                                if (elements_val['source_mapping']['lines'][0]-1) in linesnumber:
                                                    lines[elements_val['source_mapping']['lines'][0]-1] = content_val[:len(content_val)-1] + "、" + element['check'] + '\n'
                                                else:
                                                    lines[elements_val['source_mapping']['lines'][0]-1] = content_val[:len(content_val)-1] + " //StAs //" + element['check'] + '\n'
                                                    linesnumber.append(elements_val['source_mapping']['lines'][0]-1)
                                                pasteif = True
                                        elif 'start' in elements_val['source_mapping']:
                                            line_num, char_num = get_linenum_from_startcharnum(lines_chars, elements_val['source_mapping']['start'])
                                            content_val = lines[line_num-1]
                                            # if element['check'] not in holeloop:
                                            #     holeloop[element['check']] = []
                                            # holeloop[element['check']].append(line_num)
                                            if (line_num-1) in linesnumber:
                                                lines[line_num-1] = content_val[:len(content_val)-1] + "、" + element['check'] + '\n'
                                            else:
                                                lines[line_num-1] = content_val[:len(content_val)-1] + " //StAs //" + element['check'] + '\n'
                                                linesnumber.append(line_num-1)
                                            pasteif = True
                        if not pasteif:
                            for elements_val in element['elements']:
                                if 'type' in elements_val and elements_val['type'] == "contract":
                                    if 'source_mapping' in elements_val:
                                        if 'lines' in elements_val['source_mapping']:
                                            if elements_val['source_mapping']['lines']:
                                                content_val = lines[elements_val['source_mapping']['lines'][0]-1]
                                                # if element['check'] not in holeloop:
                                                #     holeloop[element['check']] = []
                                                # holeloop[element['check']].append(elements_val['source_mapping']['lines'][0])
                                                if (elements_val['source_mapping']['lines'][0]-1) in linesnumber:
                                                    lines[elements_val['source_mapping']['lines'][0]-1] = content_val[:len(content_val)-1] + "、" + element['check'] + '\n'
                                                else:
                                                    lines[elements_val['source_mapping']['lines'][0]-1] = content_val[:len(content_val)-1] + " //StAs //" + element['check'] + '\n'
                                                    linesnumber.append(elements_val['source_mapping']['lines'][0]-1)
                                                pasteif = True
                                        elif 'start' in elements_val['source_mapping']:
                                            line_num, char_num = get_linenum_from_startcharnum(lines_chars, elements_val['source_mapping']['start'])
                                            content_val = lines[line_num-1]
                                            # if element['check'] not in holeloop:
                                            #     holeloop[element['check']] = []
                                            # holeloop[element['check']].append(line_num)
                                            if (line_num-1) in linesnumber:
                                                lines[line_num-1] = content_val[:len(content_val)-1] + "、" + element['check'] + '\n'
                                            else:
                                                lines[line_num-1] = content_val[:len(content_val)-1] + " //StAs //" + element['check'] + '\n'
                                                linesnumber.append(line_num-1)
                                            pasteif = True
                        if not pasteif:
                            for elements_val in element['elements']:
                                if 'source_mapping' in elements_val:
                                    if 'lines' in elements_val['source_mapping']:
                                        if elements_val['source_mapping']['lines']:
                                            content_val = lines[elements_val['source_mapping']['lines'][0]-1]
                                            # if element['check'] not in holeloop:
                                            #     holeloop[element['check']] = []
                                            # holeloop[element['check']].append(elements_val['source_mapping']['lines'][0])
                                            if (elements_val['source_mapping']['lines'][0]-1) in linesnumber:
                                                lines[elements_val['source_mapping']['lines'][0]-1] = content_val[:len(content_val)-1] + "、" + element['check'] + '\n'
                                            else:
                                                lines[elements_val['source_mapping']['lines'][0]-1] = content_val[:len(content_val)-1] + " //StAs //" + element['check'] + '\n'
                                                linesnumber.append(elements_val['source_mapping']['lines'][0]-1)
                                            pasteif = True
                                    elif 'start' in elements_val['source_mapping']:
                                        line_num, char_num = get_linenum_from_startcharnum(lines_chars, elements_val['source_mapping']['start'])
                                        content_val = lines[line_num-1]
                                        # if element['check'] not in holeloop:
                                        #     holeloop[element['check']] = []
                                        # holeloop[element['check']].append(line_num)
                                        if (line_num-1) in linesnumber:
                                            lines[line_num-1] = content_val[:len(content_val)-1] + "、" + element['check'] + '\n'
                                        else:
                                            lines[line_num-1] = content_val[:len(content_val)-1] + " //StAs //" + element['check'] + '\n'
                                            linesnumber.append(line_num-1)
                                        pasteif = True
                for i in range(len(lines)-1):
                    if lines[i]:
                        # print(lines[i])
                        auditcontent = auditcontent + lines[i].replace("\t","&#160;&#160;&#160;&#160;").replace(" ","&#160;").replace("\n","<br/>")
                if lines[len(lines)-1]:
                    # print(lines[len(lines)-1])
                    auditcontent = auditcontent + lines[len(lines)-1].replace("\t","&#160;&#160;&#160;&#160;").replace(" ","&#160;").replace("\n","")
                    # print(lines[len(lines)-1])
                # print(auditcontent)

        if outputting_report or outputting_report_main:     
            result_maps = {}
            for val in results_detectors:
                if val['check'] not in result_maps.keys():
                    result_maps[val['check']] = []
                result_maps[val['check']].append(val)
            # print(args.report)
            # print(auditcontent)
            # print(result_maps)
            # print(filename)
            # print(time_start)
            # print(auditcontent)
            # print(contracts_names)
            # print(auditid)
            if outputting_report or outputting_report_main:
                rep = ReportEnglish()
                if outputting_report:
                    rep._output(result_maps, filename, time_start, auditcontent, args.report, contracts_names, auditid)
                if outputting_report_main:
                    rep._output_main(result_maps, filename, time_start, auditcontent, args.report_main, contracts_names, auditid)
            # if outputting_report_chinese or outputting_report_main_chinese:
            #     rep = ReportChinese()
            #     if outputting_report_chinese:
            #         rep._output(result_maps, filename, time_start, auditcontent, args.report_chinese, contracts_names, auditid)
            #     if outputting_report_main_chinese:
            #         rep._output_main(result_maps, filename, time_start, auditcontent, args.report_main_chinese, contracts_names, auditid)
        
        # print('audittime:' + str(audit_time))
        # holeloops_json = json.dumps(holeloops)
        # print(holeloops_json)

    except Exception:
        output_error = traceback.format_exc()
        logging.error(traceback.print_exc())
        logging.error('Error in %s' % args.filename)
        logging.error(output_error)

    if args.perf:
        cp.disable()
        stats = pstats.Stats(cp).sort_stats("cumtime")
        stats.print_stats()

    # Exit with the appropriate status code
    if output_error:
        sys.exit(-1)
    else:
        if len(detector_classes) == 0 :
            sys.exit(-2)
        else:
            exit(results_detectors)

if __name__ == "__main__":
    main()

# endregion
