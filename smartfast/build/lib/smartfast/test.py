# -*- coding:utf-8 -*-
import jpype
from jpype import *
import os.path
from smartfast.xmlanalysis import Xmlanalysis

def main():
	xmlanalysis = Xmlanalysis()
	result = xmlanalysis._analysispath("tests/low_level_calls.sol")
	print(result)
	result = xmlanalysis._analysispath("tests/const_state_variables.sol")
	print(result)
	xmlanalysis._shutdownjvm()

if __name__ == '__main__':
    	main()