// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {TokenShop} from "../src/TokenShop.sol";

contract DeployTokenShop is Script {
    // Sepolia ETH/USD price feed address
    // For local testing, we'll use a mock
    address constant SEPOLIA_PRICE_FEED = 0x694AA1769357215DE4FAC081bf1f309aDC325306;

    function run() external returns (TokenShop) {
        vm.startBroadcast();
        
        // For local Anvil, use address(1) as mock
        // For Sepolia, use SEPOLIA_PRICE_FEED
        TokenShop shop = new TokenShop(address(1));
        
        console.log("TokenShop deployed at:", address(shop));
        console.log("Token name:", shop.name());
        console.log("Token symbol:", shop.symbol());
        
        vm.stopBroadcast();
        return shop;
    }
}