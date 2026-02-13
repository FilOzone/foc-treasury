pragma solidity ^0.8.33;

import {Test} from "forge-std/Test.sol";
import {Bootstrap} from "erc8109/interfaces/Bootstrap.sol";

import {BecomeAdmin} from "../src/bootstrap/BecomeAdmin.sol";
import {Authorization} from "../src/gen/TreasuryStorageView.sol";
import {
    AppointAdministrator,
    AppointTreasurer,
    DismissAdministrator,
    DismissTreasurer
} from "../src/impl/AuthAdmin.sol";
import {Install, Uninstall} from "../src/impl/ProxyAdmin.sol";
import {ITreasury} from "../src/interfaces/ITreasury.sol";

uint256 constant UNAUTHORIZED = 0;
uint256 constant ADMIN = 1;
uint256 constant TREASURER = 2;

contract AuthAdminTest is Test {
    address internal proxy;
    ITreasury internal treasury;
    address internal unauthorized;
    address internal admin;
    address internal treasurer;

    function setUp() public {
        proxy = deployCode("lib/erc8109/out/Proxy.constructor.evm/Proxy.constructor.json");

        Bootstrap(proxy).configure(BecomeAdmin.becomeAdministrator.selector, address(new BecomeAdmin()));
        Bootstrap(proxy).configure(ITreasury.install.selector, address(new Install()));

        BecomeAdmin(proxy).becomeAdministrator();

        treasury = ITreasury(proxy);
        treasury.install(ITreasury.uninstall.selector, address(new Uninstall()));
        treasury.install(ITreasury.appointAdministrator.selector, address(new AppointAdministrator()));
        treasury.install(ITreasury.dismissAdministrator.selector, address(new DismissAdministrator()));
        treasury.install(ITreasury.appointTreasurer.selector, address(new AppointTreasurer()));
        treasury.install(ITreasury.dismissTreasurer.selector, address(new DismissTreasurer()));
        treasury.install(ITreasury.authorization.selector, address(new Authorization()));

        treasury.uninstall(Bootstrap.configure.selector);
        treasury.uninstall(BecomeAdmin.becomeAdministrator.selector);

        admin = makeAddr("admin");
        treasurer = makeAddr("treasurer");
        unauthorized = makeAddr("thief");
    }

    function testUnauthorized() public {
        treasury.appointTreasurer(treasurer);

        assertEq(treasury.authorization(unauthorized), UNAUTHORIZED);
        assertEq(treasury.authorization(treasurer), TREASURER);
        assertEq(treasury.authorization(address(this)), ADMIN);

        vm.startPrank(unauthorized);

        vm.expectRevert(abi.encodeWithSelector(ITreasury.Unauthorized.selector, unauthorized, ADMIN));
        treasury.appointAdministrator(admin);

        vm.expectRevert(abi.encodeWithSelector(ITreasury.Unauthorized.selector, unauthorized, ADMIN));
        treasury.dismissAdministrator(address(this));

        vm.expectRevert(abi.encodeWithSelector(ITreasury.Unauthorized.selector, unauthorized, ADMIN));
        treasury.appointTreasurer(treasurer);

        vm.expectRevert(abi.encodeWithSelector(ITreasury.Unauthorized.selector, unauthorized, ADMIN));
        treasury.dismissTreasurer(treasurer);
    }

    function testAppointDismissTreasurer() public {
        assertEq(treasury.authorization(unauthorized), UNAUTHORIZED);
        assertEq(treasury.authorization(treasurer), UNAUTHORIZED);

        treasury.appointTreasurer(treasurer);

        assertEq(treasury.authorization(unauthorized), UNAUTHORIZED);
        assertEq(treasury.authorization(treasurer), TREASURER);

        treasury.dismissTreasurer(treasurer);

        assertEq(treasury.authorization(treasurer), UNAUTHORIZED);
    }

    function testAppointDismissAdministrator() public {
        assertEq(treasury.authorization(unauthorized), UNAUTHORIZED);
        assertEq(treasury.authorization(admin), UNAUTHORIZED);

        treasury.appointAdministrator(admin);

        assertEq(treasury.authorization(unauthorized), UNAUTHORIZED);
        assertEq(treasury.authorization(admin), ADMIN);

        treasury.dismissAdministrator(admin);

        assertEq(treasury.authorization(admin), UNAUTHORIZED);
    }
}
