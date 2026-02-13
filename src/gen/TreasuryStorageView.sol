pragma solidity ^0.8.33;

import {ProxyStorageBase} from "erc8109/ProxyStorageBase.sol";

// Generated with make src/gen/TreasuryStorageView.sol

contract Authorization is ProxyStorageBase {
    mapping(address who => uint256 permissions) public authorization;
    mapping(address who => uint256 grant) internal granted;
    uint256 internal allocated;
    uint256 internal dispersed;
}

contract Granted is ProxyStorageBase {
    mapping(address who => uint256 permissions) internal authorization;
    mapping(address who => uint256 grant) public granted;
    uint256 internal allocated;
    uint256 internal dispersed;
}

contract Allocated is ProxyStorageBase {
    mapping(address who => uint256 permissions) internal authorization;
    mapping(address who => uint256 grant) internal granted;
    uint256 public allocated;
    uint256 internal dispersed;
}

contract Dispersed is ProxyStorageBase {
    mapping(address who => uint256 permissions) internal authorization;
    mapping(address who => uint256 grant) internal granted;
    uint256 internal allocated;
    uint256 public dispersed;
}
