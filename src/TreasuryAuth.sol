pragma solidity ^0.8.33;

import {ITreasury} from "./interfaces/ITreasury.sol";
import {TreasuryStorage} from "./TreasuryStorage.sol";

contract TreasuryAuth is TreasuryStorage {
    uint256 internal constant ADMIN = 1;
    uint256 internal constant TREASURER = 2;
    //uint256 internal constant  = 4;

    event Appoint(address who, uint256 roles);
    event Dismiss(address who, uint256 roles);

    function auth(address who, uint256 requiredPermissions) internal view {
        require(
            authorization[who] & requiredPermissions == requiredPermissions,
            ITreasury.Unauthorized(who, requiredPermissions)
        );
    }

    function appoint(address who, uint256 roles) internal {
        authorization[who] |= roles;
        emit Appoint(who, roles);
    }

    function dismiss(address who, uint256 roles) internal {
        authorization[who] &= ~roles;
        emit Dismiss(who, roles);
    }

    modifier onlyAdmin() {
        auth(msg.sender, ADMIN);
        _;
    }

    modifier onlyTreasurer() {
        auth(msg.sender, TREASURER);
        _;
    }
}
