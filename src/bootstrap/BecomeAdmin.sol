pragma solidity ^0.8.33;

import {TreasuryAuth} from "../TreasuryAuth.sol";
import {ITreasury} from "../interfaces/ITreasury.sol";

contract BecomeAdmin is TreasuryAuth {
    address public immutable ADMINISTRATOR;

    constructor() {
        ADMINISTRATOR = msg.sender;
    }

    function becomeAdministrator() external {
        require(msg.sender == ADMINISTRATOR, ITreasury.Unauthorized(msg.sender, ADMIN));
        appoint(ADMINISTRATOR, ADMIN);
    }
}
