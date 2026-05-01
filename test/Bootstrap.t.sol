pragma solidity ^0.8.33;

import {Test} from "forge-std/Test.sol";
import {Bootstrap} from "erc8167/interfaces/Bootstrap.sol";
import {IERC8167} from "erc8167/interfaces/IERC8167.sol";

contract ProxyAdminTest is Test {
    Bootstrap internal proxy;
    address internal unauthorized;

    function setUp() public {
        proxy = Bootstrap(deployCode("lib/erc8167/out/Proxy.constructor.evm/Proxy.constructor.json"));

        unauthorized = makeAddr("thief");
    }

    function testBootstrapConfigure() public {
        IERC8167 viewer = IERC8167(address(proxy));

        vm.expectRevert(
            abi.encodeWithSelector(IERC8167.FunctionNotFound.selector, IERC8167.implementation.selector)
        );
        viewer.implementation(IERC8167.implementation.selector);

        address implementationImpl = deployCode("lib/erc8167/out/implementation.evm/implementation.json");
        vm.expectEmit();
        emit IERC8167.SelectorDelegated(IERC8167.implementation.selector, implementationImpl);
        proxy.configure(IERC8167.implementation.selector, implementationImpl);

        assertEq(viewer.implementation(IERC8167.implementation.selector), implementationImpl);

        address bootstrapImpl = vm.computeCreateAddress(address(proxy), 1);
        assertEq(viewer.implementation(Bootstrap.configure.selector), bootstrapImpl);
    }

    function testBootstrapConfigureUnauthorized() public {
        address implementationImpl = deployCode("lib/erc8167/out/implementation.evm/implementation.json");

        vm.expectRevert(abi.encodeWithSelector(Bootstrap.Unauthorized.selector, unauthorized));
        vm.prank(unauthorized);
        proxy.configure(IERC8167.implementation.selector, implementationImpl);
    }
}
