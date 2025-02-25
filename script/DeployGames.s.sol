// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {Games} from "../src/Games.sol";

contract DeployGames is Script {
    function run() public {
        // Start broadcasting transactions
        vm.startBroadcast();

        // Deploy the contract
        Games games = new Games();

        vm.stopBroadcast();
    }
}
