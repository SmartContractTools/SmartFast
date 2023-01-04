import sys
from smartfast.smartfast import Smartfast


if len(sys.argv) != 2:
    print("python export_dominator_tree_to_dot.py contract.sol")
    sys.exit(-1)

# Init smartfast
smartfast = Smartfast(sys.argv[1])

for contract in smartfast.contracts:
    for function in list(contract.functions) + list(contract.modifiers):
        filename = "{}-{}-{}_dom.dot".format(sys.argv[1], contract.name, function.full_name)
        print("Export {}".format(filename))
        function.dominator_tree_to_dot(filename)
