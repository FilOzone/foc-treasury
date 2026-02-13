pragma solidity ^0.8.33;

import { IFilecoinPay } from "./IFilecoinPay.sol";

interface ITreasury {
    // TreasuryAuth
    error Unauthorized(address who, uint256 requiredAuthorization);

    // public view
    function authorization(address who) external view returns (uint256 permissions);
    function granted(address who) external view returns (uint256 grant);
    function allocated() external view returns (uint256 allocated);
    function dispersed() external view returns (uint256 dispersed);
    // calculated
    function available() external view returns (uint256 available);
    function reserved() external view returns (uint256 reserved);

    // onlyTreasurer
    function grant(address who, uint256 wad) external;
    function withhold(address who, uint256 wad) external;

    // user
    function withdraw(address payable to, uint256 wad) external;
    function depositTo(IFilecoinPay where, address to, uint256 wad) external;
}
