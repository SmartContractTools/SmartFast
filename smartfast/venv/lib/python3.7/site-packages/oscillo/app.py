# -*- coding: utf-8 -*-
import argparse
import json
import sys

import yaml

from oscillo import worker


def get_command_list(commands_str_list):
    # name:cmd,name:cmd
    try:
        sp = [item.split(':', 1) for item in commands_str_list]
        return [{"name": c[0].strip(), "cmd": c[1].strip()} for c in sp]
    except IndexError:
        raise ValueError('command list should be formatted in: name:cmd')


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '-g', '--globals',
        action='store_true',
        default=False,
        help='Watch global load (cpu, memory). Default is `False`'
    )
    parser.add_argument(
        '--config',
        help='config file: which specified the command list and the name of metrix text file'
    )

    parser.add_argument(
        '-l', '--load',
        help='reload metrics file and print to image'
    )

    parser.add_argument(
        '-c', '--commands',
        nargs='*',
        help='specify the commands list instead of config file: <flag1>:<command1>,<flag2>:<command2>...'
    )

    parser.add_argument(
        '-o', '--output',
        help='target file name to output'
    )

    args = parser.parse_args()

    desc = 'Record the system load at the execution of the command line and display it graphically\n'

    _config = None
    if args.commands:
        commands = get_command_list(args.commands)
        output = args.output
        _config = {'commands': commands, 'output': output}
    elif args.config:
        _conf_file = args.config
        with open(_conf_file, "r") as f:
            _config = yaml.load(f)

    _load_log_file = args.load

    if not _config and not _load_log_file:
        print(desc)
        parser.print_help()
        sys.exit(1)

    if _load_log_file:
        with open(_load_log_file, "r") as f:
            _summary = json.load(f)
        _output = _load_log_file

    else:

        _output = _config.get("output") or 'metrix'
        _summary = worker.run_commands(_config, args.globals)
        with open(_output + ".log", "w") as f:
            json.dump(_summary, f)
    worker.print_image(_summary, _output)


if __name__ == '__main__':
    main()
