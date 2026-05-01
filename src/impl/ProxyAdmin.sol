pragma solidity ^0.8.33;

import {IERC8167} from "erc8167/interfaces/IERC8167.sol";
import {ITreasury} from "../interfaces/ITreasury.sol";
import {TreasuryAuth} from "../TreasuryAuth.sol";

address constant FUNCTION_NOT_FOUND = address(0x0000000000000000000000000000000000000000);

contract Install is TreasuryAuth {
    function install(bytes4 selector, address delegate) external onlyAdmin {
        require(delegate != FUNCTION_NOT_FOUND, ITreasury.MissingDelegate());
        require(delegates[selector] == FUNCTION_NOT_FOUND, ITreasury.FunctionExists(selector));
        delegates[selector] = delegate;
        emit IERC8167.SelectorDelegated(selector, delegate);
    }
}

contract Upgrade is TreasuryAuth {
    function upgrade(bytes4 selector, address delegate) external onlyAdmin {
        require(delegate != FUNCTION_NOT_FOUND, ITreasury.MissingDelegate());
        require(delegates[selector] != FUNCTION_NOT_FOUND, IERC8167.FunctionNotFound(selector));
        delegates[selector] = delegate;
        emit IERC8167.SelectorDelegated(selector, delegate);
    }
}

contract Uninstall is TreasuryAuth {
    function uninstall(bytes4 selector) external onlyAdmin {
        require(delegates[selector] != FUNCTION_NOT_FOUND, IERC8167.FunctionNotFound(selector));
        delegates[selector] = FUNCTION_NOT_FOUND;
        emit IERC8167.SelectorDelegated(selector, FUNCTION_NOT_FOUND);
    }
}
