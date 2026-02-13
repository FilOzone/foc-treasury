pragma solidity ^0.8.33;

import {FVMPay} from "fvm-solidity/FVMPay.sol";

import {IFilecoinPay, NATIVE_TOKEN} from "../interfaces/IFilecoinPay.sol";
import {ITreasury} from "../interfaces/ITreasury.sol";
import {TreasuryStorage} from "../TreasuryStorage.sol";
import {TreasuryAuth} from "../TreasuryAuth.sol";

uint256 constant MAX_GRANT = 2000000000 ether;

contract Grant is TreasuryAuth {
    function grant(address who, uint256 wad) external onlyTreasurer {
        require(wad <= MAX_GRANT, ITreasury.OversizedGrant(wad));
        granted[who] += wad;
        allocated += wad;
    }
}

contract Withhold is TreasuryAuth {
    function withhold(address who, uint256 wad) external onlyTreasurer {
        uint256 grant = granted[who];
        if (wad > grant) {
            granted[who] = 0;
            allocated -= grant;
        } else {
            granted[who] = grant - wad;
            allocated -= wad;
        }
    }
}

contract Withdraw is TreasuryStorage {
    using FVMPay for address payable;

    function withdraw(address payable to, uint256 wad) external {
        granted[msg.sender] -= wad;
        dispersed += wad;
        require(to.pay(wad), ITreasury.PaymentFailure());
    }
}

contract DepositTo is TreasuryStorage {
    function depositTo(IFilecoinPay where, address to, uint256 wad) external {
        granted[msg.sender] -= wad;
        dispersed += wad;
        where.deposit{value: wad}(NATIVE_TOKEN, to, wad);
    }
}
