pragma solidity ^0.8.33;

import {Bootstrap} from "erc8109/interfaces/Bootstrap.sol";
import {stdError} from "forge-std/StdError.sol";
import {MockFVMTest} from "fvm-solidity/mocks/MockFVMTest.sol";

import {BecomeAdmin} from "../src/bootstrap/BecomeAdmin.sol";
import {Allocated, Authorization, Dispersed, Granted} from "../src/gen/TreasuryStorageView.sol";
import {IFilecoinPay, NATIVE_TOKEN} from "../src/interfaces/IFilecoinPay.sol";
import {ITreasury} from "../src/interfaces/ITreasury.sol";
import {AppointTreasurer} from "../src/impl/AuthAdmin.sol";
import {Available, DepositTo, Grant, MAX_GRANT, Reserved, Withdraw, Withhold} from "../src/impl/Grants.sol";
import {Install, Uninstall} from "../src/impl/ProxyAdmin.sol";

uint256 constant TREASURER = 2;

contract MockFilecoinPay is IFilecoinPay {
    mapping(address user => uint256 balance) public balances;

    // exclude from coverage
    function test() public pure {}

    function deposit(address token, address to, uint256 wad) external payable {
        require(token == NATIVE_TOKEN);
        require(wad == msg.value);
        balances[to] += wad;
    }
}

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
        treasury.install(ITreasury.available.selector, address(new Available()));
        treasury.install(ITreasury.authorization.selector, address(new Authorization()));
        treasury.install(ITreasury.dispersed.selector, address(new Dispersed()));
        treasury.install(ITreasury.granted.selector, address(new Granted()));
        treasury.install(ITreasury.reserved.selector, address(new Reserved()));

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

    function testWithholdUnauthorized() public {
        vm.expectRevert(abi.encodeWithSelector(ITreasury.Unauthorized.selector, address(this), TREASURER));
        treasury.withhold(unauthorized, 10 ** 18);
    }

    function testOversizedGrant() public {
        vm.prank(treasurer);
        vm.expectRevert(abi.encodeWithSelector(ITreasury.OversizedGrant.selector, MAX_GRANT + 1));
        treasury.grant(unauthorized, MAX_GRANT + 1);

        assertEq(treasury.granted(unauthorized), 0);

        vm.prank(treasurer);
        treasury.grant(unauthorized, MAX_GRANT);

        assertEq(treasury.granted(unauthorized), MAX_GRANT);
    }

    function testWithdrawGrant() public {
        assertEq(treasury.granted(unauthorized), 0);
        assertEq(treasury.allocated(), 0);
        assertEq(treasury.available(), 0);
        assertEq(treasury.dispersed(), 0);
        assertEq(treasury.reserved(), 0);

        vm.prank(treasurer);
        treasury.grant(unauthorized, 1 ether);

        assertEq(treasury.granted(unauthorized), 1 ether);
        assertEq(treasury.allocated(), 1 ether);
        assertEq(treasury.available(), 0);
        assertEq(treasury.dispersed(), 0);
        assertEq(treasury.reserved(), 1 ether);

        vm.prank(unauthorized);
        vm.expectRevert(stdError.arithmeticError);
        treasury.withdraw(recipient, 1 ether + 1);

        vm.prank(unauthorized);
        vm.expectRevert(abi.encodeWithSelector(ITreasury.PaymentFailure.selector));
        treasury.withdraw(recipient, 1 ether);

        assertEq(unauthorized.balance, 0);
        assertEq(recipient.balance, 0);

        vm.deal(proxy, 4 ether);
        assertEq(treasury.available(), 3 ether);

        vm.prank(unauthorized);
        treasury.withdraw(recipient, 1 ether);

        assertEq(unauthorized.balance, 0);
        assertEq(recipient.balance, 1 ether);
        assertEq(treasury.granted(unauthorized), 0);
        assertEq(treasury.available(), 3 ether);
        assertEq(treasury.allocated(), 1 ether);
        assertEq(treasury.dispersed(), 1 ether);
        assertEq(treasury.reserved(), 0);
    }

    function testWithholdGrant() public {
        assertEq(treasury.granted(unauthorized), 0);
        assertEq(treasury.allocated(), 0);
        assertEq(treasury.dispersed(), 0);

        vm.prank(treasurer);
        treasury.grant(unauthorized, 3 ether);

        assertEq(treasury.granted(unauthorized), 3 ether);
        assertEq(treasury.allocated(), 3 ether);
        assertEq(treasury.dispersed(), 0);

        vm.prank(treasurer);
        treasury.withhold(unauthorized, 1 ether);

        assertEq(treasury.granted(unauthorized), 2 ether);
        assertEq(treasury.allocated(), 2 ether);
        assertEq(treasury.dispersed(), 0);

        vm.prank(treasurer);
        treasury.withhold(unauthorized, 3 ether);

        assertEq(treasury.granted(unauthorized), 0);
        assertEq(treasury.allocated(), 0);
        assertEq(treasury.dispersed(), 0);
    }

    function testDepositGrant() public {
        MockFilecoinPay filecoinPay = new MockFilecoinPay();

        vm.prank(unauthorized);
        vm.expectRevert(stdError.arithmeticError);
        treasury.depositTo(filecoinPay, recipient, 2 ether);

        assertEq(treasury.reserved(), 0);

        vm.prank(treasurer);
        treasury.grant(unauthorized, 1 ether);

        assertEq(treasury.reserved(), 1 ether);

        vm.prank(unauthorized);
        vm.expectRevert();
        treasury.depositTo(filecoinPay, recipient, 1 ether);

        assertEq(filecoinPay.balances(recipient), 0);

        vm.deal(proxy, 1 ether);
        vm.prank(unauthorized);
        treasury.depositTo(filecoinPay, recipient, 1 ether);

        assertEq(filecoinPay.balances(recipient), 1 ether);
        assertEq(recipient.balance, 0);
        assertEq(treasury.granted(unauthorized), 0);
        assertEq(treasury.allocated(), 1 ether);
        assertEq(treasury.available(), 0);
        assertEq(treasury.dispersed(), 1 ether);
        assertEq(treasury.reserved(), 0);
    }
}
