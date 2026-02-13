#!/bin/bash

CONTRACT_START=$(grep -n contract $1 | cut -f1 -d:)

# Copy header
head -n $((CONTRACT_START - 1)) $1

echo \/\/ Generated with make src/gen/TreasuryStorageView.sol
echo

# These line numbers contain "internal"
INTERNAL_LINES=$(grep -n internal $1 | cut -f1 -d:)

# create contracts making individual internals public
for line in $INTERNAL_LINES; do
    NAME=$(sed -n "${line}s/.*[[:space:]]\([^[:space:]]*\);/\1/p" $1 | sed 's/^./\U&/')
    sed "${line}s/internal/public/;${CONTRACT_START}s/TreasuryStorage/$NAME/" $1 | tail -n +$CONTRACT_START
done
