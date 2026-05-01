pragma solidity ^0.8.33;

// Generated with make src/gen/Selectors.sol

contract Selectors {
    function selectors() external pure returns (bytes4[] memory methods) {
        methods = new bytes4[](19);

        //  allocated() view returns (uint256)
        methods[0] = 0xb304b2e1;

        //  appointAdministrator(address) nonpayable
        methods[1] = 0x6969d5d8;

        //  appointTreasurer(address) nonpayable
        methods[2] = 0x39ae5108;

        //  authorization(address) view returns (uint256)
        methods[3] = 0xcbe12969;

        //  available() view returns (uint256)
        methods[4] = 0x48a0d754;

        //  depositTo(IFilecoinPay,address,uint256) nonpayable
        methods[5] = 0xf213159c;

        //  dismissAdministrator(address) nonpayable
        methods[6] = 0xb60a79b2;

        //  dismissTreasurer(address) nonpayable
        methods[7] = 0x469a8dbd;

        //  dispersed() view returns (uint256)
        methods[8] = 0x8e3d1e1a;

        //  grant(address,uint256) nonpayable
        methods[9] = 0x6370920e;

        //  granted(address) view returns (uint256)
        methods[10] = 0x85aa6e09;

        //  implementation(bytes4) view returns (address)
        methods[11] = 0x0d741577;

        //  install(bytes4,address) nonpayable
        methods[12] = 0xe18404dc;

        //  reserved() view returns (uint256)
        methods[13] = 0xfe60d12c;

        //  selectors() view returns (bytes4[])
        methods[14] = 0x6e25b978;

        //  uninstall(bytes4) nonpayable
        methods[15] = 0x6030c5d1;

        //  upgrade(bytes4,address) nonpayable
        methods[16] = 0x5c37d65a;

        //  withdraw(address payable,uint256) nonpayable
        methods[17] = 0xf3fef3a3;

        //  withhold(address,uint256) nonpayable
        methods[18] = 0xd68e462c;
    }
}
