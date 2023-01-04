#!/usr/bin/env bash

### Test smartfast-prop

cd examples/smartfast-prop || exit 1
smartfast-prop . --contract ERC20Buggy
if [ ! -f contracts/crytic/TestERC20BuggyTransferable.sol ]; then
    echo "smartfast-prop failed"
    return 1
fi
