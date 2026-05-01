pragma solidity ^0.8.33;

import {Bootstrap} from "erc8167/interfaces/Bootstrap.sol";
import {IERC8167} from "erc8167/interfaces/IERC8167.sol";
import {Test} from "forge-std/Test.sol";

import {BecomeAdmin} from "../src/bootstrap/BecomeAdmin.sol";
import {DeployTreasury} from "../script/DeployTreasury.s.sol";

contract DeployTreasuryTest is Test {
    function testDeployTreasury() public {
        IERC8167 proxy = new DeployTreasury().deploy();

        // ensure all selectors have been configured
        bytes4[] memory selectors = proxy.selectors();
        for (uint256 i = 0; i < selectors.length; i++) {
            address implementation = proxy.implementation(selectors[i]);
            assertNotEq(implementation, address(0));
            for (uint256 j = 0; j < i; j++) {
                // ensure each selectors has a different delegate
                assertNotEq(implementation, proxy.implementation(selectors[j]));
            }
        }
        // check expected number of delegates
        assertEq(selectors.length, 19);

        // ensure bootstrapping delegates were uninstalled
        assertEq(proxy.implementation(BecomeAdmin.becomeAdministrator.selector), address(0));
        assertEq(proxy.implementation(Bootstrap.configure.selector), address(0));
    }
}
