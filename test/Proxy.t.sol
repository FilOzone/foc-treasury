pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";

import {Bootstrap} from "erc8109/interfaces/Bootstrap.sol";
import {IERC8109Minimal} from "erc8109/interfaces/IERC8109Minimal.sol";

contract ProxyTest is Test {
    address internal proxy;

    function setUp() public {
        proxy = deployCode("lib/erc8109/out/Proxy.constructor.evm/Proxy.constructor.json");
    }

    function testFunctionNotFound() public {
        vm.expectRevert(
            abi.encodeWithSelector(IERC8109Minimal.FunctionNotFound.selector, IERC8109Minimal.facetAddress.selector)
        );
        IERC8109Minimal(proxy).facetAddress(Bootstrap.configure.selector);
    }

    function testBootstrapConfigureUnauthorized() public {
        address unauthorized = makeAddr("thief");
        vm.expectRevert(abi.encodeWithSelector(Bootstrap.Unauthorized.selector, unauthorized));
        vm.prank(unauthorized);
        Bootstrap(proxy).configure(Bootstrap.configure.selector, address(this));
    }

    function testBootstrapConfigureIntrospect() public {
        address facetAddressImpl = deployCode("lib/erc8109/out/facetAddress.evm/facetAddress.json");
        assertEq(facetAddressImpl.code.length, 15);

        vm.expectEmit();
        emit IERC8109Minimal.SetDiamondFacet(IERC8109Minimal.facetAddress.selector, facetAddressImpl);
        Bootstrap(proxy).configure(IERC8109Minimal.facetAddress.selector, facetAddressImpl);

        assertEq(IERC8109Minimal(proxy).facetAddress(IERC8109Minimal.facetAddress.selector), facetAddressImpl);
    }
}
