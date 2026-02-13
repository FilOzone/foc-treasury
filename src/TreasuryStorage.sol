pragma solidity ^0.8.33;

import {ProxyStorageBase} from "erc8109/ProxyStorageBase.sol";

contract TreasuryStorage is ProxyStorageBase {
    mapping(address who => uint256 permissions) internal authorization;
    mapping(address who => uint256 grant) internal granted;
    uint256 internal allocated;
    uint256 internal dispersed;
}
