#!/bin/bash

#forge build $1 >&2

INTERFACE=$(sed -nE 's/interface ([[:alnum:]]+).*/\1/p' $1)

#  selectors(bytes4) view returns (address) | 0x4932fe01
ABI_INSPECTION=$(forge inspect $1:$INTERFACE abi | grep function | cut -d \| -f 3-4)
COUNT=$(wc -l <<< "$ABI_INSPECTION")

cat <<EOF
pragma solidity ^0.8.33;

// Generated with make src/gen/Selectors.sol

contract Selectors {
    function selectors() external pure returns (bytes4[] memory methods) {
        methods = new bytes4[]($COUNT);
EOF
INDEX=0
while IFS= read -r funcInfo; do
    echo
    IFS='|' read sig selector <<< "$funcInfo"
    echo "        // $sig"
    echo -n "        methods[$INDEX] = "
    echo -n $selector
    echo \;
    ((INDEX++))
done <<< "$ABI_INSPECTION"

cat <<EOF
    }
}
EOF
