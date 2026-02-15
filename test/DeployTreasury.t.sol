pragma solidity ^0.8.33;

import {Bootstrap} from "erc8109/interfaces/Bootstrap.sol";
import {IERC8109Minimal} from "erc8109/interfaces/IERC8109Minimal.sol";
import {Test} from "forge-std/Test.sol";

import {BecomeAdmin} from "../src/bootstrap/BecomeAdmin.sol";
import {DeployTreasury} from "../script/DeployTreasury.s.sol";

contract DeployTreasuryTest is Test {
    function testDeployTreasury() public {
        IERC8109Minimal proxy = new DeployTreasury().deploy();

        // ensure all pairs have been configured
        IERC8109Minimal.FunctionFacetPair[] memory pairs = proxy.functionFacetPairs();
        for (uint256 i = 0; i < pairs.length; i++) {
            assertNotEq(pairs[i].facet, address(0));
        }
        // ensure functionFacetPairs matches facetAddress
        for (uint256 i = 0; i < pairs.length; i++) {
            assertEq(pairs[i].facet, proxy.facetAddress(pairs[i].selector));
        }
        // check expected number of facets
        assertEq(pairs.length, 19);

        // ensure bootstrapping facets were uninstalled
        assertEq(proxy.facetAddress(BecomeAdmin.becomeAdministrator.selector), address(0));
        assertEq(proxy.facetAddress(Bootstrap.configure.selector), address(0));
    }
}
