import sys
from smartfast.smartfast import Smartfast
from smartfast.smartir.convert import convert_expression


if len(sys.argv) != 2:
    print("python function_called.py functions_called.sol")
    sys.exit(-1)

# Init smartfast
smartfast = Smartfast(sys.argv[1])

# Get the contract
contract = smartfast.get_contract_from_name("Test")
assert contract
# Get the variable
test = contract.get_function_from_signature("one()")
assert test
nodes = test.nodes

for node in nodes:
    if node.expression:
        print("Expression:\n\t{}".format(node.expression))
        irs = convert_expression(node.expression, node)
        print("IR expressions:")
        for ir in irs:
            print("\t{}".format(ir))
        print()
