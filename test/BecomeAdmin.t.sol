pragma solidity ^0.8.33;

import {Test} from "forge-std/Test.sol";
import {Bootstrap} from "erc8109/interfaces/Bootstrap.sol";

import {BecomeAdmin} from "../src/bootstrap/BecomeAdmin.sol";
import {Authorization} from "../src/gen/TreasuryStorageView.sol";
import {ITreasury} from "../src/interfaces/ITreasury.sol";

uint256 constant UNAUTHORIZED = 0;
uint256 constant ADMIN = 1;

contract BecomeAdminTest is Test {
    address internal proxy;
    address internal unauthorized;

    function setUp() public {
        proxy = deployCode("lib/erc8109/out/Proxy.constructor.evm/Proxy.constructor.json");

        unauthorized = makeAddr("thief");
    }

    function testBecomeAdministrator() public {
        vm.prank(unauthorized);
        BecomeAdmin becomeAdmin = new BecomeAdmin();

        assertEq(becomeAdmin.ADMINISTRATOR(), unauthorized);

        Bootstrap(proxy).configure(becomeAdmin.ADMINISTRATOR.selector, address(becomeAdmin));
        assertEq(BecomeAdmin(proxy).ADMINISTRATOR(), unauthorized);

        Bootstrap(proxy).configure(BecomeAdmin.becomeAdministrator.selector, address(becomeAdmin));

        vm.expectRevert(abi.encodeWithSelector(ITreasury.Unauthorized.selector, address(this), ADMIN));
        BecomeAdmin(proxy).becomeAdministrator();

        Bootstrap(proxy).configure(ITreasury.authorization.selector, address(new Authorization()));
        assertEq(ITreasury(proxy).authorization(unauthorized), UNAUTHORIZED);

        vm.prank(unauthorized);
        vm.expectEmit();
        emit ITreasury.Appoint(unauthorized, ADMIN);
        BecomeAdmin(proxy).becomeAdministrator();

        assertEq(ITreasury(proxy).authorization(unauthorized), ADMIN);
    }
}
