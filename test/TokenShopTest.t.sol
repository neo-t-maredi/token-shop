// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {TokenShop} from "../src/TokenShop.sol";
import {MockV3Aggregator} from "./mocks/MockV3Aggregator.sol";

contract TokenShopTest is Test {
    TokenShop public shop;
    MockV3Aggregator public priceFeed;
    
    address public BUYER = makeAddr("buyer");
    uint256 public constant STARTING_BALANCE = 10 ether;
    int256 public constant ETH_USD_PRICE = 2000e8; // $2000 with 8 decimals

    function setUp() public {
        // Deploy mock price feed
        priceFeed = new MockV3Aggregator(8, ETH_USD_PRICE);
        // Deploy shop with mock
        shop = new TokenShop(address(priceFeed));
        // Fund buyer
        vm.deal(BUYER, STARTING_BALANCE);
    }

    // Test deployment
    function test_Deployment() public view {
        assertEq(shop.name(), "ShopToken");
        assertEq(shop.symbol(), "SHOP");
    }

    // Test price feed works
    function test_GetEthPrice() public view {
        uint256 price = shop.getEthPriceUsd();
        assertEq(price, 2000e18); // Scaled to 18 decimals
    }

    // Test buying tokens
    function test_BuyTokens() public {
        vm.prank(BUYER);
        shop.buyTokens{value: 1 ether}();
        
        // 1 ETH at $2000 = 2000 tokens
        assertEq(shop.balanceOf(BUYER), 2000e18);
    }

    // Test selling tokens
    function test_SellTokens() public {
        // First buy some tokens
        vm.prank(BUYER);
        shop.buyTokens{value: 1 ether}();
        
        uint256 balanceBefore = BUYER.balance;
        
        // Sell half
        vm.prank(BUYER);
        shop.sellTokens(1000e18);
        
        assertEq(shop.balanceOf(BUYER), 1000e18);
        assertGt(BUYER.balance, balanceBefore);
    }

    // Test token amount calculation
    function test_GetTokenAmount() public view {
        uint256 tokens = shop.getTokenAmount(1 ether);
        assertEq(tokens, 2000e18);
    }

    // Test revert on zero ETH
    function test_RevertOnZeroEth() public {
        vm.prank(BUYER);
        vm.expectRevert(TokenShop.TokenShop__NotEnoughEth.selector);
        shop.buyTokens{value: 0}();
    }

    // Test only owner can withdraw
    function test_OnlyOwnerCanWithdraw() public {
        vm.prank(BUYER);
        vm.expectRevert(TokenShop.TokenShop__NotOwner.selector);
        shop.withdraw();
    }
}