#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import print_function

import os
import subprocess
import sys
import threading
import time

import matplotlib
import numpy as np
import psutil

from . import table

if not os.environ.get('DISPLAY'):
    print('DISPLAY not found. Using non-interactive Agg backend')
    matplotlib.use('Agg')

import matplotlib.pyplot as plt


class Stopwatch(object):

    def __init__(self, pid):
        self.__is_run = False
        self.__start_time = 0
        self.__elapsed_times = 0
        self.memory_percent = []
        self.cpu_percent = []
        self.pid = pid

    def start(self):
        if self.__is_run:
            return False
        self.__is_run = True
        self.__start_time = time.time()

        if self.pid > 0:
            p = psutil.Process(self.pid)
        else:
            p = psutil
            p.memory_percent = lambda: p.virtual_memory().percent
        while self.__is_run:
            try:
                self.cpu_percent.append(p.cpu_percent(1))
                self.memory_percent.append(p.memory_percent())
            except psutil.NoSuchProcess:
                break

    @property
    def elapsed(self):

        if self.__is_run:
            return self.__elapsed_times + time.time() - self.__start_time
        return self.__elapsed_times

    def stop(self):
        self.__elapsed_times = self.elapsed
        self.__is_run = False

    @property
    def cpu(self):
        return self.cpu_percent

    @property
    def memory(self):
        return self.memory_percent

    @property
    def current_cpu(self):
        if not self.cpu_percent:
            return 0
        return self.cpu_percent[-1]

    @property
    def current_memory(self):
        if not self.memory_percent:
            return 0
        return self.memory_percent[-1]


class Runner(object):

    def __init__(self, name, cmd, global_mode):
        self.name = name
        self.cmd = cmd
        self.global_mode = global_mode
        self.stopwatch = None

    @property
    def process_id(self):
        if self.global_mode:
            return -1
        else:
            return self._process().pid

    def run(self):
        self.stopwatch = Stopwatch(self.process_id)
        thread = threading.Thread(target=self.stopwatch.start)
        thread.setDaemon(True)
        thread.start()

        self._run_subprocess()

        self.stopwatch.stop()

        return {
            "cpu": self.stopwatch.cpu,
            "memory": self.stopwatch.memory,
            "elapsed": self.stopwatch.elapsed
        }

    def _run_subprocess(self):
        raise NotImplementedError

    def _process(self):
        raise NotImplementedError


class RunnerWithPrintTitle(Runner):
    def __init__(self, name, cmd, index, global_mode=False):
        super(RunnerWithPrintTitle, self).__init__(name, cmd, global_mode)
        self.index = index
        self.process = subprocess.Popen(self.cmd,
                                        stdin=sys.stdin,
                                        stdout=sys.stdout,
                                        stderr=sys.stderr,
                                        shell=True
                                        )

    def _run_subprocess(self):
        table_data = [
            [str(self.index), ''],
        ]
        t = table.get_table(table_data, title=' execute command ')
        wrapped_string = table.wrap_long_text_to_table(t, self.cmd)
        t.table_data[0][1] = wrapped_string

        print(t.table)

        self.process.communicate()

        elapsed = round(self.stopwatch.elapsed, 3)
        max_cpu_load = "{}%".format(round(max(self.stopwatch.cpu), 3)) if self.stopwatch.cpu else '0%'
        max_memory_load = "{}%".format(round(max(self.stopwatch.memory), 3)) if self.stopwatch.memory else '0%'

        result_data = [
            ['run', 'elapsed(s)', 'cpu (max)', 'memory (max)', 'return code'],
            ['', elapsed, max_cpu_load, max_memory_load, self.process.returncode]
        ]
        t = table.get_table(result_data, title=' result of command ')
        wrapped_string = table.wrap_long_text_to_table(t, self.cmd)
        t.table_data[1][0] = wrapped_string
        print(t.table)

    def _process(self):
        return self.process


def run_commands(config, global_resource):
    commands = config['commands']

    summary = {}

    for index, command in enumerate(commands):
        index += 1
        name = command.get("name")
        cmd = command.get("cmd")

        runner = RunnerWithPrintTitle(name=name, cmd=cmd, index=index,
                                      global_mode=global_resource)
        summary[name] = runner.run()
    return summary


def print_image(summary, output="metrix.png"):
    plt.figure(figsize=(16, 4))

    plt.subplot(121)
    for k in summary:
        result = summary[k]
        x = np.linspace(0, int(result['elapsed']), len(result['cpu']))
        y = np.array(result['cpu'])

        plt.plot(x, y, label=k, linewidth=2)

    plt.xlabel("Time(s)")
    plt.ylabel("CPU (%)")
    plt.legend(labels=[k for k in summary], loc="best")
    plt.title("CPU load tracing")

    plt.subplot(122)
    for k in summary:
        result = summary[k]
        x = np.linspace(0, int(result['elapsed']), len(result['memory']))
        y = np.array(result['memory'])

        plt.plot(x, y, label=k, linewidth=2)
    plt.xlabel("Time(s)")
    plt.ylabel("Memory (%)")
    plt.legend(labels=[k for k in summary], loc="best")
    plt.title("Memory load tracing")

    if not output.endswith('.png'):
        output += '.png'
    plt.savefig(output)
