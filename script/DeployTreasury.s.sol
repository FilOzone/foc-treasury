pragma solidity ^0.8.33;

import {Bootstrap} from "erc8167/interfaces/Bootstrap.sol";
import {IERC8167} from "erc8167/interfaces/IERC8167.sol";
import {Script} from "forge-std/Script.sol";

import {BecomeAdmin} from "../src/bootstrap/BecomeAdmin.sol";
import {Selectors} from "../src/gen/Selectors.sol";
import {Authorization, Granted, Allocated, Dispersed} from "../src/gen/TreasuryStorageView.sol";
import {ITreasury} from "../src/interfaces/ITreasury.sol";
import {
    AppointAdministrator, AppointTreasurer, DismissAdministrator, DismissTreasurer
} from "../src/impl/AuthAdmin.sol";
import {Grant, Withhold, Withdraw, DepositTo, Available, Reserved} from "../src/impl/Grants.sol";
import {Install, Upgrade, Uninstall} from "../src/impl/ProxyAdmin.sol";

contract DeployTreasury is Script {
    function deploy() public returns (ITreasury treasury) {
        address proxy = deployCode("lib/erc8167/out/Proxy.constructor.evm/Proxy.constructor.json");
        Bootstrap(proxy).configure(BecomeAdmin.becomeAdministrator.selector, address(new BecomeAdmin()));
        Bootstrap(proxy).configure(ITreasury.install.selector, address(new Install()));
        BecomeAdmin(proxy).becomeAdministrator();

        treasury = ITreasury(proxy);
        treasury.install(ITreasury.uninstall.selector, address(new Uninstall()));

        treasury.install(ITreasury.allocated.selector, address(new Allocated()));
        treasury.install(ITreasury.appointAdministrator.selector, address(new AppointAdministrator()));
        treasury.install(ITreasury.appointTreasurer.selector, address(new AppointTreasurer()));
        treasury.install(ITreasury.authorization.selector, address(new Authorization()));
        treasury.install(ITreasury.available.selector, address(new Available()));
        treasury.install(ITreasury.depositTo.selector, address(new DepositTo()));
        treasury.install(ITreasury.dismissAdministrator.selector, address(new DismissAdministrator()));
        treasury.install(ITreasury.dismissTreasurer.selector, address(new DismissTreasurer()));
        treasury.install(ITreasury.dispersed.selector, address(new Dispersed()));
        treasury.install(
            IERC8167.implementation.selector, deployCode("lib/erc8167/out/implementation.evm/implementation.json")
        );
        treasury.install(IERC8167.selectors.selector, address(new Selectors()));
        treasury.install(ITreasury.grant.selector, address(new Grant()));
        treasury.install(ITreasury.granted.selector, address(new Granted()));
        //treasury.install(ITreasury.install.selector, address(new Install()));
        treasury.install(ITreasury.reserved.selector, address(new Reserved()));
        //treasury.install(ITreasury.uninstall.selector, address(new Uninstall()));
        treasury.install(ITreasury.upgrade.selector, address(new Upgrade()));
        treasury.install(ITreasury.withdraw.selector, address(new Withdraw()));
        treasury.install(ITreasury.withhold.selector, address(new Withhold()));

        treasury.uninstall(Bootstrap.configure.selector);
        treasury.uninstall(BecomeAdmin.becomeAdministrator.selector);
    }
}
