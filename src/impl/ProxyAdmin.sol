pragma solidity ^0.8.33;

import {IERC8109Minimal} from "erc8109/interfaces/IERC8109Minimal.sol";
import {ITreasury} from "../interfaces/ITreasury.sol";
import {TreasuryAuth} from "../TreasuryAuth.sol";

address constant FUNCTION_NOT_FOUND = address(0x0000000000000000000000000000000000000000);

contract Install is TreasuryAuth {
    function install(bytes4 selector, address delegate) external onlyAdmin {
        require(selectorToFacet[selector] == FUNCTION_NOT_FOUND, ITreasury.FunctionExists(selector));
        require(delegate != FUNCTION_NOT_FOUND, ITreasury.MissingDelegate());
        selectorToFacet[selector] = delegate;
        emit IERC8109Minimal.SetDiamondFacet(selector, delegate);
    }
}

contract Upgrade is TreasuryAuth {
    function upgrade(bytes4 selector, address delegate) external onlyAdmin {
        require(selectorToFacet[selector] != FUNCTION_NOT_FOUND, IERC8109Minimal.FunctionNotFound(selector));
        require(delegate != FUNCTION_NOT_FOUND, ITreasury.MissingDelegate());
        selectorToFacet[selector] = delegate;
        emit IERC8109Minimal.SetDiamondFacet(selector, delegate);
    }
}

contract Uninstall is TreasuryAuth {
    function uninstall(bytes4 selector) external onlyAdmin {
        require(selectorToFacet[selector] != FUNCTION_NOT_FOUND, IERC8109Minimal.FunctionNotFound(selector));
        selectorToFacet[selector] = FUNCTION_NOT_FOUND;
        emit IERC8109Minimal.SetDiamondFacet(selector, FUNCTION_NOT_FOUND);
    }
}
