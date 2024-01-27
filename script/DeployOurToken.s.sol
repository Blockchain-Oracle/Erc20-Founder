// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {OurToken} from "../src/OurToken.sol";

contract DeployOurToken is Script {
    uint256 public deployerKey;
    uint256 public constant INITIAL_SUPPLY = 1000 ether;

    constructor() {
        if (block.chainid == 11155111) {
            deployerKey = vm.envUint("PRIVATE_KEY");
        }
        if (block.chainid == 31337) {
            deployerKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        }
    }

    function run() public returns (OurToken) {
        vm.startBroadcast(deployerKey);
        OurToken ourToken = new OurToken(INITIAL_SUPPLY);
        vm.stopBroadcast();
        return ourToken;
    }
}
