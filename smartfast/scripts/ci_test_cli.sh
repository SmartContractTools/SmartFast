#!/usr/bin/env bash

### Test

solc use 0.7.0

if ! smartfast "tests/config/test.sol" --solc-ast --ignore-return-value; then
    echo "--solc-ast failed"
    exit 1
fi

if ! smartfast "tests/config/test.sol" --solc-disable-warnings --ignore-return-value; then
    echo "--solc-disable-warnings failed"
    exit 1
fi

if ! smartfast "tests/config/test.sol" --disable-color --ignore-return-value; then
    echo "--disable-color failed"
    exit 1
fi
