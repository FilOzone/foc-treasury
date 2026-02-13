pragma solidity ^0.8.33;

address constant NATIVE_TOKEN = address(0x0000000000000000000000000000000000000000);

interface IFilecoinPay {
    function deposit(address token, address to, uint256 wad) external payable;
}
