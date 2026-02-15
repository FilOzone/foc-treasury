#!/bin/bash

#forge build $1 >&2

INTERFACE=$(sed -nE 's/interface ([[:alnum:]]+).*/\1/p' $1)

#  facetAddress(bytes4) view returns (address)                             | 0xcdffacc6
ABI_INSPECTION=$(forge inspect $1:$INTERFACE abi | grep function | cut -d \| -f 3-4)
COUNT=$(wc -l <<< "$ABI_INSPECTION")

cat <<EOF
pragma solidity ^0.8.33;

import {ProxyStorageBase} from "erc8109/ProxyStorageBase.sol";
import {IERC8109Minimal} from "erc8109/interfaces/IERC8109Minimal.sol";

// Generated with make src/gen/FunctionFacetPairs.sol

contract FunctionFacetPairs is ProxyStorageBase {
    function functionFacetPairs() external view returns (IERC8109Minimal.FunctionFacetPair[] memory pairs) {
        pairs = new IERC8109Minimal.FunctionFacetPair[]($COUNT);
EOF
INDEX=0
while IFS= read -r funcInfo; do
    echo
    IFS='|' read sig selector <<< "$funcInfo"
    echo "        // $sig"
    echo -n "        pairs[$INDEX].selector = "
    echo -n $selector
    echo \;
    echo -n "        pairs[$INDEX].facet = selectorToFacet["
    echo -n $selector
    echo ]\;
    ((INDEX++))
done <<< "$ABI_INSPECTION"

cat <<EOF
    }
}
EOF
