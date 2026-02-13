pragma solidity ^0.8.33;

import {Test} from "forge-std/Test.sol";
import {Bootstrap} from "erc8109/interfaces/Bootstrap.sol";
import {IERC8109Minimal} from "erc8109/interfaces/IERC8109Minimal.sol";

import {BecomeAdmin} from "../src/bootstrap/BecomeAdmin.sol";
import {ITreasury} from "../src/interfaces/ITreasury.sol";
import {FUNCTION_NOT_FOUND, Install, Uninstall, Upgrade} from "../src/impl/ProxyAdmin.sol";

uint256 constant ADMIN = 1;

contract ProxyAdminTest is Test {
    ITreasury internal treasury;
    address internal unauthorized;

    function setUp() public {
        address proxy = deployCode("lib/erc8109/out/Proxy.constructor.evm/Proxy.constructor.json");

        // bootstrap
        Bootstrap(proxy).configure(BecomeAdmin.becomeAdministrator.selector, address(new BecomeAdmin()));
        Bootstrap(proxy).configure(ITreasury.install.selector, address(new Install()));
        BecomeAdmin(proxy).becomeAdministrator();

        treasury = ITreasury(proxy);

        // finish setup
        treasury.install(ITreasury.uninstall.selector, address(new Uninstall()));
        treasury.install(ITreasury.upgrade.selector, address(new Upgrade()));
        treasury.install(
            IERC8109Minimal.facetAddress.selector, deployCode("lib/erc8109/out/facetAddress.evm/facetAddress.json")
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
            abi.encodeWithSelector(IERC8109Minimal.FunctionNotFound.selector, BecomeAdmin.becomeAdministrator.selector)
        );
        treasury.uninstall(BecomeAdmin.becomeAdministrator.selector);
    }

    function testInstall() public {
        assertEq(treasury.facetAddress(BecomeAdmin.becomeAdministrator.selector), FUNCTION_NOT_FOUND);

        vm.prank(unauthorized);
        BecomeAdmin becomeAdmin = new BecomeAdmin();

        vm.expectEmit();
        emit IERC8109Minimal.SetDiamondFacet(BecomeAdmin.becomeAdministrator.selector, address(becomeAdmin));
        treasury.install(BecomeAdmin.becomeAdministrator.selector, address(becomeAdmin));

        assertEq(treasury.facetAddress(BecomeAdmin.becomeAdministrator.selector), address(becomeAdmin));

        vm.prank(unauthorized);
        BecomeAdmin(address(treasury)).becomeAdministrator();
    }

    function testUpgrade() public {
        address installDelegate2 = address(new Install());

        vm.expectEmit();
        emit IERC8109Minimal.SetDiamondFacet(ITreasury.install.selector, installDelegate2);
        treasury.upgrade(ITreasury.install.selector, installDelegate2);

        assertEq(treasury.facetAddress(ITreasury.install.selector), installDelegate2);
    }

    function testUninstall() public {
        vm.expectEmit();
        emit IERC8109Minimal.SetDiamondFacet(ITreasury.install.selector, FUNCTION_NOT_FOUND);
        treasury.uninstall(ITreasury.install.selector);

        assertEq(treasury.facetAddress(ITreasury.install.selector), FUNCTION_NOT_FOUND);

        address installDelegate = address(new Install());
        vm.expectRevert(abi.encodeWithSelector(IERC8109Minimal.FunctionNotFound.selector, ITreasury.install.selector));
        treasury.install(ITreasury.install.selector, installDelegate);
    }

    function testInstallOnlyAdmin() public {
        vm.prank(unauthorized);
        BecomeAdmin becomeAdmin = new BecomeAdmin();

        vm.expectRevert(abi.encodeWithSelector(ITreasury.Unauthorized.selector, unauthorized, ADMIN));
        vm.prank(unauthorized);
        treasury.install(BecomeAdmin.becomeAdministrator.selector, address(becomeAdmin));

        assertEq(treasury.facetAddress(BecomeAdmin.becomeAdministrator.selector), FUNCTION_NOT_FOUND);
    }

    function testUninstallOnlyAdmin() public {
        address installDelegate = treasury.facetAddress(ITreasury.install.selector);

        vm.expectRevert(abi.encodeWithSelector(ITreasury.Unauthorized.selector, unauthorized, ADMIN));
        vm.prank(unauthorized);
        treasury.uninstall(ITreasury.install.selector);

        assertEq(treasury.facetAddress(ITreasury.install.selector), installDelegate);
    }

    function testUpgradeOnlyAdmin() public {
        address installDelegate = treasury.facetAddress(ITreasury.install.selector);
        address installDelegate2 = address(new Install());

        vm.expectRevert(abi.encodeWithSelector(ITreasury.Unauthorized.selector, unauthorized, ADMIN));
        vm.prank(unauthorized);
        treasury.upgrade(ITreasury.install.selector, installDelegate2);

        assertEq(treasury.facetAddress(ITreasury.install.selector), installDelegate);
    }
}
