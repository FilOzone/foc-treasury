pragma solidity ^0.8.33;

import { ITreasury } from "./interfaces/ITreasury.sol";
import { TreasuryStorage } from "./TreasuryStorage.sol";

contract TreasuryAuth is TreasuryStorage {
    uint256 private constant ADMIN = 1;
    uint256 private constant TREASURER = 2;
    //uint256 internal constant  = 4;

    function auth(address who, uint256 requiredPermissions) internal view {
        require(
            authorization[who] & requiredPermissions == requiredPermissions,
            ITreasury.Unauthorized(who, requiredPermissions)
        );
    }

    modifier onlyAdmin {
        auth(msg.sender, ADMIN);
        _;
    }

    modifier onlyTreasurer {
        auth(msg.sender, TREASURER);
        _;
    }
}
