import sys
from smartfast import Smartfast

if len(sys.argv) != 2:
    print("python smartIR.py contract.sol")
    sys.exit(-1)

# Init smartfast
smartfast = Smartfast(sys.argv[1])

# Iterate over all the contracts
for contract in smartfast.contracts:

    # Iterate over all the functions
    for function in contract.functions:

        # Dont explore inherited functions
        if function.contract_declarer == contract:

            print("Function: {}".format(function.name))

            # Iterate over the nodes of the function
            for node in function.nodes:

                # Print the Solidity expression of the nodes
                # And the SmartIR operations
                if node.expression:

                    print("\tSolidity expression: {}".format(node.expression))
                    print("\tSmartIR:")
                    for ir in node.irs:
                        print("\t\t\t{}".format(ir))
