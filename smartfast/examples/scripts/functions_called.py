import sys
from smartfast.smartfast import Smartfast

if len(sys.argv) != 2:
    print("python functions_called.py functions_called.sol")
    sys.exit(-1)

# Init smartfast
smartfast = Smartfast(sys.argv[1])

# Get the contract
contract = smartfast.get_contract_from_name("Contract")
assert contract

# Get the variable
entry_point = contract.get_function_from_signature("entry_point()")
assert entry_point

all_calls = entry_point.all_internal_calls()

all_calls_formated = [f.canonical_name for f in all_calls]

# Print the result
print("From entry_point the functions reached are {}".format(all_calls_formated))
