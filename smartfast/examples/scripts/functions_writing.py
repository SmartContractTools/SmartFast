import sys
from smartfast.smartfast import Smartfast

if len(sys.argv) != 2:
    print("python function_writing.py functions_writing.sol")
    sys.exit(-1)

# Init smartfast
smartfast = Smartfast(sys.argv[1])

# Get the contract
contract = smartfast.get_contract_from_name("Contract")

# Get the variable
var_a = contract.get_state_variable_from_name("a")

# Get the functions writing the variable
functions_writing_a = contract.get_functions_writing_to_variable(var_a)

# Print the result
print('The function writing "a" are {}'.format([f.name for f in functions_writing_a]))
