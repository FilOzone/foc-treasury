pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";

import {Bootstrap} from "erc8167/interfaces/Bootstrap.sol";
import {IERC8167} from "erc8167/interfaces/IERC8167.sol";

address constant FUNCTION_NOT_FOUND = address(0x0000000000000000000000000000000000000000);

contract ProxyTest is Test {
    address internal proxy;
    address internal bootstrapImpl;

    function setUp() public {
        proxy = deployCode("lib/erc8167/out/Proxy.constructor.evm/Proxy.constructor.json");
        bootstrapImpl = vm.computeCreateAddress(proxy, 1);
    }

    function testFunctionNotFound() public {
        vm.expectRevert(abi.encodeWithSelector(IERC8167.FunctionNotFound.selector, IERC8167.implementation.selector));
        IERC8167(proxy).implementation(Bootstrap.configure.selector);
    }

    function testBootstrapConfigureUnauthorized() public {
        address unauthorized = makeAddr("thief");
        vm.expectRevert(abi.encodeWithSelector(Bootstrap.Unauthorized.selector, unauthorized));
        vm.prank(unauthorized);
        Bootstrap(proxy).configure(Bootstrap.configure.selector, address(this));
    }

    function testBootstrapConfigureIntrospect() public {
        address implementationImpl = deployCode("lib/erc8167/out/implementation.evm/implementation.json");

        vm.expectEmit();
        emit IERC8167.SelectorDelegated(IERC8167.implementation.selector, implementationImpl);
        Bootstrap(proxy).configure(IERC8167.implementation.selector, implementationImpl);

        assertEq(IERC8167(proxy).implementation(IERC8167.implementation.selector), implementationImpl);
        assertEq(IERC8167(proxy).implementation(Bootstrap.configure.selector), bootstrapImpl);

        vm.expectEmit();
        emit IERC8167.SelectorDelegated(Bootstrap.configure.selector, FUNCTION_NOT_FOUND);
        Bootstrap(proxy).configure(Bootstrap.configure.selector, FUNCTION_NOT_FOUND);

        assertEq(IERC8167(proxy).implementation(IERC8167.implementation.selector), implementationImpl);
        assertEq(IERC8167(proxy).implementation(Bootstrap.configure.selector), FUNCTION_NOT_FOUND);
    }
}
