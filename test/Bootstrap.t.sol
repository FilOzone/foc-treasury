pragma solidity ^0.8.33;

import {Test} from "forge-std/Test.sol";
import {Bootstrap} from "erc8109/interfaces/Bootstrap.sol";
import {IERC8109Minimal} from "erc8109/interfaces/IERC8109Minimal.sol";

contract ProxyAdminTest is Test {
    Bootstrap internal proxy;
    address internal unauthorized;

    function setUp() public {
        proxy = Bootstrap(deployCode("lib/erc8109/out/Proxy.constructor.evm/Proxy.constructor.json"));

        unauthorized = makeAddr("thief");
    }

    function testBootstrapConfigure() public {
        IERC8109Minimal viewer = IERC8109Minimal(address(proxy));

        vm.expectRevert(
            abi.encodeWithSelector(IERC8109Minimal.FunctionNotFound.selector, IERC8109Minimal.facetAddress.selector)
        );
        viewer.facetAddress(IERC8109Minimal.facetAddress.selector);

        address facetAddressImpl = deployCode("lib/erc8109/out/facetAddress.evm/facetAddress.json");
        vm.expectEmit();
        emit IERC8109Minimal.SetDiamondFacet(IERC8109Minimal.facetAddress.selector, facetAddressImpl);
        proxy.configure(IERC8109Minimal.facetAddress.selector, facetAddressImpl);

        assertEq(viewer.facetAddress(IERC8109Minimal.facetAddress.selector), facetAddressImpl);

        address bootstrapImpl = vm.computeCreateAddress(address(proxy), 1);
        assertEq(viewer.facetAddress(Bootstrap.configure.selector), bootstrapImpl);
    }

    function testBootstrapConfigureUnauthorized() public {
        address facetAddressImpl = deployCode("lib/erc8109/out/facetAddress.evm/facetAddress.json");

        vm.expectRevert(abi.encodeWithSelector(Bootstrap.Unauthorized.selector, unauthorized));
        vm.prank(unauthorized);
        proxy.configure(IERC8109Minimal.facetAddress.selector, facetAddressImpl);
    }
}
