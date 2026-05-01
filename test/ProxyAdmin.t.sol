pragma solidity ^0.8.33;

import {Test} from "forge-std/Test.sol";
import {Bootstrap} from "erc8167/interfaces/Bootstrap.sol";
import {IERC8167} from "erc8167/interfaces/IERC8167.sol";

import {BecomeAdmin} from "../src/bootstrap/BecomeAdmin.sol";
import {ITreasury} from "../src/interfaces/ITreasury.sol";
import {FUNCTION_NOT_FOUND, Install, Uninstall, Upgrade} from "../src/impl/ProxyAdmin.sol";

uint256 constant ADMIN = 1;

contract ProxyAdminTest is Test {
    ITreasury internal treasury;
    address internal unauthorized;

    function setUp() public {
        address proxy = deployCode("lib/erc8167/out/Proxy.constructor.evm/Proxy.constructor.json");

        // bootstrap
        Bootstrap(proxy).configure(BecomeAdmin.becomeAdministrator.selector, address(new BecomeAdmin()));
        Bootstrap(proxy).configure(ITreasury.install.selector, address(new Install()));
        BecomeAdmin(proxy).becomeAdministrator();

        treasury = ITreasury(proxy);

        // finish setup
        treasury.install(ITreasury.uninstall.selector, address(new Uninstall()));
        treasury.install(ITreasury.upgrade.selector, address(new Upgrade()));
        treasury.install(
            IERC8167.implementation.selector, deployCode("lib/erc8167/out/implementation.evm/implementation.json")
        );

        // remove bootstrap
        treasury.uninstall(Bootstrap.configure.selector);
        treasury.uninstall(BecomeAdmin.becomeAdministrator.selector);

        unauthorized = makeAddr("thief");
    }

    function testInstallFunctionExists() public {
        address installDelegate = address(new Install());

        vm.expectRevert(abi.encodeWithSelector(ITreasury.FunctionExists.selector, ITreasury.install.selector));
        treasury.install(ITreasury.install.selector, installDelegate);
    }

    function testInstallMissingDelegate() public {
        vm.expectRevert(abi.encodeWithSelector(ITreasury.MissingDelegate.selector));
        treasury.install(BecomeAdmin.becomeAdministrator.selector, FUNCTION_NOT_FOUND);
    }

    function testUpgradeMissingDelegate() public {
        vm.expectRevert(abi.encodeWithSelector(ITreasury.MissingDelegate.selector));
        treasury.upgrade(ITreasury.install.selector, FUNCTION_NOT_FOUND);
    }

    function testUninstallFunctionNotFound() public {
        vm.expectRevert(
            abi.encodeWithSelector(IERC8167.FunctionNotFound.selector, BecomeAdmin.becomeAdministrator.selector)
        );
        treasury.uninstall(BecomeAdmin.becomeAdministrator.selector);
    }

    function testUpgradeFunctionNotFound() public {
        address delegate = address(new BecomeAdmin());
        vm.expectRevert(
            abi.encodeWithSelector(IERC8167.FunctionNotFound.selector, BecomeAdmin.becomeAdministrator.selector)
        );
        treasury.upgrade(BecomeAdmin.becomeAdministrator.selector, delegate);
    }

    function testInstall() public {
        assertEq(treasury.implementation(BecomeAdmin.becomeAdministrator.selector), FUNCTION_NOT_FOUND);

        vm.prank(unauthorized);
        BecomeAdmin becomeAdmin = new BecomeAdmin();

        vm.expectEmit();
        emit IERC8167.SelectorDelegated(BecomeAdmin.becomeAdministrator.selector, address(becomeAdmin));
        treasury.install(BecomeAdmin.becomeAdministrator.selector, address(becomeAdmin));

        assertEq(treasury.implementation(BecomeAdmin.becomeAdministrator.selector), address(becomeAdmin));

        vm.prank(unauthorized);
        BecomeAdmin(address(treasury)).becomeAdministrator();
    }

    function testUpgrade() public {
        address installDelegate2 = address(new Install());

        vm.expectEmit();
        emit IERC8167.SelectorDelegated(ITreasury.install.selector, installDelegate2);
        treasury.upgrade(ITreasury.install.selector, installDelegate2);

        assertEq(treasury.implementation(ITreasury.install.selector), installDelegate2);
    }

    function testUninstall() public {
        vm.expectEmit();
        emit IERC8167.SelectorDelegated(ITreasury.install.selector, FUNCTION_NOT_FOUND);
        treasury.uninstall(ITreasury.install.selector);

        assertEq(treasury.implementation(ITreasury.install.selector), FUNCTION_NOT_FOUND);

        address installDelegate = address(new Install());
        vm.expectRevert(abi.encodeWithSelector(IERC8167.FunctionNotFound.selector, ITreasury.install.selector));
        treasury.install(ITreasury.install.selector, installDelegate);
    }

    function testInstallOnlyAdmin() public {
        vm.prank(unauthorized);
        BecomeAdmin becomeAdmin = new BecomeAdmin();

        vm.expectRevert(abi.encodeWithSelector(ITreasury.Unauthorized.selector, unauthorized, ADMIN));
        vm.prank(unauthorized);
        treasury.install(BecomeAdmin.becomeAdministrator.selector, address(becomeAdmin));

        assertEq(treasury.implementation(BecomeAdmin.becomeAdministrator.selector), FUNCTION_NOT_FOUND);
    }

    function testUninstallOnlyAdmin() public {
        address installDelegate = treasury.implementation(ITreasury.install.selector);

        vm.expectRevert(abi.encodeWithSelector(ITreasury.Unauthorized.selector, unauthorized, ADMIN));
        vm.prank(unauthorized);
        treasury.uninstall(ITreasury.install.selector);

        assertEq(treasury.implementation(ITreasury.install.selector), installDelegate);
    }

    function testUpgradeOnlyAdmin() public {
        address installDelegate = treasury.implementation(ITreasury.install.selector);
        address installDelegate2 = address(new Install());

        vm.expectRevert(abi.encodeWithSelector(ITreasury.Unauthorized.selector, unauthorized, ADMIN));
        vm.prank(unauthorized);
        treasury.upgrade(ITreasury.install.selector, installDelegate2);

        assertEq(treasury.implementation(ITreasury.install.selector), installDelegate);
    }
}
