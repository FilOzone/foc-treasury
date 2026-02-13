pragma solidity ^0.8.33;

import {IERC8109Minimal} from "erc8109/interfaces/IERC8109Minimal.sol";
import {IFilecoinPay} from "./IFilecoinPay.sol";

interface ITreasury is IERC8109Minimal {
    // TreasuryAuth
    error Unauthorized(address who, uint256 requiredAuthorization);
    event Appoint(address who, uint256 roles);
    event Dismiss(address who, uint256 roles);

    // public view
    function authorization(address who) external view returns (uint256 permissions);
    function granted(address who) external view returns (uint256 grant);
    function allocated() external view returns (uint256 allocated);
    function dispersed() external view returns (uint256 dispersed);
    // calculated
    function available() external view returns (uint256);
    function reserved() external view returns (uint256);

    // onlyTreasurer
    error OversizedGrant(uint256 wad);
    function grant(address who, uint256 wad) external;
    function withhold(address who, uint256 wad) external;

    // user
    error PaymentFailure();
    function withdraw(address payable to, uint256 wad) external;
    function depositTo(IFilecoinPay where, address to, uint256 wad) external;

    // proxy onlyAdmin
    error FunctionExists(bytes4 selector);
    error MissingDelegate();
    function install(bytes4 selector, address delegate) external;
    function upgrade(bytes4 selector, address delegate) external;
    function uninstall(bytes4 selector) external;

    // auth onlyAdmin
    function appointAdministrator(address admin) external;
    function dismissAdministrator(address admin) external;
    function appointTreasurer(address treasurer) external;
    function dismissTreasurer(address treasurer) external;
}
