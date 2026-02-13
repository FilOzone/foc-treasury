pragma solidity ^0.8.33;

import {Bootstrap} from "erc8109/interfaces/Bootstrap.sol";
import {stdError} from "forge-std/StdError.sol";
import {MockFVMTest} from "fvm-solidity/mocks/MockFVMTest.sol";

import {BecomeAdmin} from "../src/bootstrap/BecomeAdmin.sol";
import {Allocated, Authorization, Dispersed, Granted} from "../src/gen/TreasuryStorageView.sol";
import {ITreasury} from "../src/interfaces/ITreasury.sol";
import {AppointTreasurer} from "../src/impl/AuthAdmin.sol";
import {DepositTo, Grant, Withdraw, Withhold} from "../src/impl/Grants.sol";
import {Install, Uninstall} from "../src/impl/ProxyAdmin.sol";

uint256 constant TREASURER = 2;

contract GrantsTest is MockFVMTest {
    address internal proxy;
    ITreasury internal treasury;
    address internal unauthorized;
    address payable internal recipient;
    address internal treasurer;

    function setUp() public override {
        super.setUp();

        proxy = deployCode("lib/erc8109/out/Proxy.constructor.evm/Proxy.constructor.json");

        Bootstrap(proxy).configure(BecomeAdmin.becomeAdministrator.selector, address(new BecomeAdmin()));
        BecomeAdmin(proxy).becomeAdministrator();

        Bootstrap(proxy).configure(ITreasury.install.selector, address(new Install()));

        treasury = ITreasury(proxy);
        treasury.install(ITreasury.uninstall.selector, address(new Uninstall()));
        treasury.install(ITreasury.appointTreasurer.selector, address(new AppointTreasurer()));
        treasury.install(ITreasury.depositTo.selector, address(new DepositTo()));
        treasury.install(ITreasury.grant.selector, address(new Grant()));
        treasury.install(ITreasury.withdraw.selector, address(new Withdraw()));
        treasury.install(ITreasury.withhold.selector, address(new Withhold()));

        treasury.install(ITreasury.allocated.selector, address(new Allocated()));
        treasury.install(ITreasury.authorization.selector, address(new Authorization()));
        treasury.install(ITreasury.dispersed.selector, address(new Dispersed()));
        treasury.install(ITreasury.granted.selector, address(new Granted()));

        treasury.uninstall(Bootstrap.configure.selector);
        treasury.uninstall(BecomeAdmin.becomeAdministrator.selector);

        treasurer = makeAddr("treasurer");
        treasury.appointTreasurer(treasurer);

        unauthorized = makeAddr("thief");
    }

    function testGrantUnauthorized() public {
        vm.expectRevert(abi.encodeWithSelector(ITreasury.Unauthorized.selector, address(this), TREASURER));
        treasury.grant(unauthorized, 10 ** 18);
    }

    function testWithdrawGrant() public {
        assertEq(treasury.granted(unauthorized), 0);
        assertEq(treasury.allocated(), 0);
        assertEq(treasury.dispersed(), 0);

        vm.prank(treasurer);
        treasury.grant(unauthorized, 1 ether);

        assertEq(treasury.granted(unauthorized), 1 ether);
        assertEq(treasury.allocated(), 1 ether);
        assertEq(treasury.dispersed(), 0);

        vm.prank(unauthorized);
        vm.expectRevert(stdError.arithmeticError);
        treasury.withdraw(recipient, 1 ether + 1);

        vm.prank(unauthorized);
        vm.expectRevert(abi.encodeWithSelector(ITreasury.PaymentFailure.selector));
        treasury.withdraw(recipient, 1 ether);

        assertEq(unauthorized.balance, 0);
        assertEq(recipient.balance, 0);

        vm.deal(proxy, 1 ether);
        vm.prank(unauthorized);
        treasury.withdraw(recipient, 1 ether);

        assertEq(unauthorized.balance, 0);
        assertEq(recipient.balance, 1 ether);
        assertEq(treasury.granted(unauthorized), 0);
        assertEq(treasury.allocated(), 1 ether);
        assertEq(treasury.dispersed(), 1 ether);
    }
}
