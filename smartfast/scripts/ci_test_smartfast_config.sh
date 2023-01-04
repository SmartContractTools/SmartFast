#!/usr/bin/env bash

### Test

if ! smartfast "tests/*.json" --config "tests/config/smartfast.config.json"; then
    echo "Config failed"
    exit 1
fi

