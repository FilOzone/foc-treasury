pragma solidity ^0.8.33;

import {ProxyStorageBase} from "erc8109/ProxyStorageBase.sol";
import {IERC8109Minimal} from "erc8109/interfaces/IERC8109Minimal.sol";

// Generated with make src/gen/FunctionFacetPairs.sol

contract FunctionFacetPairs is ProxyStorageBase {
    function functionFacetPairs() external view returns (IERC8109Minimal.FunctionFacetPair[] memory pairs) {
        pairs = new IERC8109Minimal.FunctionFacetPair[](19);

        //  allocated() view returns (uint256)
        pairs[0].selector = 0xb304b2e1;
        pairs[0].facet = selectorToFacet[0xb304b2e1];

        //  appointAdministrator(address) nonpayable
        pairs[1].selector = 0x6969d5d8;
        pairs[1].facet = selectorToFacet[0x6969d5d8];

        //  appointTreasurer(address) nonpayable
        pairs[2].selector = 0x39ae5108;
        pairs[2].facet = selectorToFacet[0x39ae5108];

        //  authorization(address) view returns (uint256)
        pairs[3].selector = 0xcbe12969;
        pairs[3].facet = selectorToFacet[0xcbe12969];

        //  available() view returns (uint256)
        pairs[4].selector = 0x48a0d754;
        pairs[4].facet = selectorToFacet[0x48a0d754];

        //  depositTo(IFilecoinPay,address,uint256) nonpayable
        pairs[5].selector = 0xf213159c;
        pairs[5].facet = selectorToFacet[0xf213159c];

        //  dismissAdministrator(address) nonpayable
        pairs[6].selector = 0xb60a79b2;
        pairs[6].facet = selectorToFacet[0xb60a79b2];

        //  dismissTreasurer(address) nonpayable
        pairs[7].selector = 0x469a8dbd;
        pairs[7].facet = selectorToFacet[0x469a8dbd];

        //  dispersed() view returns (uint256)
        pairs[8].selector = 0x8e3d1e1a;
        pairs[8].facet = selectorToFacet[0x8e3d1e1a];

        //  facetAddress(bytes4) view returns (address)
        pairs[9].selector = 0xcdffacc6;
        pairs[9].facet = selectorToFacet[0xcdffacc6];

        //  functionFacetPairs() view returns (IERC8109Minimal.FunctionFacetPair[])
        pairs[10].selector = 0x60b5befb;
        pairs[10].facet = selectorToFacet[0x60b5befb];

        //  grant(address,uint256) nonpayable
        pairs[11].selector = 0x6370920e;
        pairs[11].facet = selectorToFacet[0x6370920e];

        //  granted(address) view returns (uint256)
        pairs[12].selector = 0x85aa6e09;
        pairs[12].facet = selectorToFacet[0x85aa6e09];

        //  install(bytes4,address) nonpayable
        pairs[13].selector = 0xe18404dc;
        pairs[13].facet = selectorToFacet[0xe18404dc];

        //  reserved() view returns (uint256)
        pairs[14].selector = 0xfe60d12c;
        pairs[14].facet = selectorToFacet[0xfe60d12c];

        //  uninstall(bytes4) nonpayable
        pairs[15].selector = 0x6030c5d1;
        pairs[15].facet = selectorToFacet[0x6030c5d1];

        //  upgrade(bytes4,address) nonpayable
        pairs[16].selector = 0x5c37d65a;
        pairs[16].facet = selectorToFacet[0x5c37d65a];

        //  withdraw(address payable,uint256) nonpayable
        pairs[17].selector = 0xf3fef3a3;
        pairs[17].facet = selectorToFacet[0xf3fef3a3];

        //  withhold(address,uint256) nonpayable
        pairs[18].selector = 0xd68e462c;
        pairs[18].facet = selectorToFacet[0xd68e462c];
    }
}
