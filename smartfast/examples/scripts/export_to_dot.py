import sys
from smartfast.smartfast import Smartfast


if len(sys.argv) != 2:
    print("python function_called.py contract.sol")
    sys.exit(-1)

# Init smartfast
smartfast = Smartfast(sys.argv[1])

for contract in smartfast.contracts:
    for function in contract.functions + contract.modifiers:
        filename = "{}-{}-{}.dot".format(sys.argv[1], contract.name, function.full_name)
        print("Export {}".format(filename))
        function.smartir_cfg_to_dot(filename)
