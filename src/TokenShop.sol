// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

/**
 * @title TokenShop
 * @author Neo Maredi
 * @notice Buy tokens with ETH using live Chainlink price feeds
 * @dev Demonstrates Chainlink Price Feed integration
 */
contract TokenShop {
    // Errors
    error TokenShop__NotEnoughEth();
    error TokenShop__TransferFailed();
    error TokenShop__NotOwner();
    error TokenShop__InsufficientTokens();

    // State variables
    AggregatorV3Interface private s_priceFeed;
    address private immutable i_owner;
    
    string public name;
    string public symbol;
    uint8 public constant DECIMALS = 18;
    uint256 public constant TOKEN_PRICE_USD = 1; // $1 per token
    
    uint256 private s_totalSupply;
    mapping(address => uint256) private s_balances;

    // Events
    event TokensPurchased(address indexed buyer, uint256 amount, uint256 ethSpent);
    event TokensSold(address indexed seller, uint256 amount, uint256 ethReceived);

    constructor(address priceFeed) {
        s_priceFeed = AggregatorV3Interface(priceFeed);
        i_owner = msg.sender;
        name = "ShopToken";
        symbol = "SHOP";
    }

    // Buy tokens with ETH at current market price
    function buyTokens() external payable {
        uint256 ethPriceUsd = getEthPriceUsd();
        uint256 tokenAmount = (msg.value * ethPriceUsd) / (TOKEN_PRICE_USD * 1e18);
        
        if (tokenAmount == 0) revert TokenShop__NotEnoughEth();
        
        s_totalSupply += tokenAmount;
        s_balances[msg.sender] += tokenAmount;
        
        emit TokensPurchased(msg.sender, tokenAmount, msg.value);
    }

    // Sell tokens back for ETH
    function sellTokens(uint256 amount) external {
        if (s_balances[msg.sender] < amount) revert TokenShop__InsufficientTokens();
        
        uint256 ethPriceUsd = getEthPriceUsd();
        uint256 ethToReturn = (amount * TOKEN_PRICE_USD * 1e18) / ethPriceUsd;
        
        s_balances[msg.sender] -= amount;
        s_totalSupply -= amount;
        
        (bool success,) = msg.sender.call{value: ethToReturn}("");
        if (!success) revert TokenShop__TransferFailed();
        
        emit TokensSold(msg.sender, amount, ethToReturn);
    }

    // Get current ETH price in USD (8 decimals from Chainlink, scaled to 18)
function getEthPriceUsd() public view returns (uint256) {
    (, int256 price,,,) = s_priceFeed.latestRoundData();
    // Safe: Chainlink prices are always positive
    // forge-lint: disable-next-line(unsafe-typecast)
    return uint256(price) * 1e10;
}

    // How many tokens can you buy with this ETH amount?
    function getTokenAmount(uint256 ethAmount) external view returns (uint256) {
        uint256 ethPriceUsd = getEthPriceUsd();
        return (ethAmount * ethPriceUsd) / (TOKEN_PRICE_USD * 1e18);
    }

    // Withdraw ETH (owner only)
    function withdraw() external {
        if (msg.sender != i_owner) revert TokenShop__NotOwner();
        (bool success,) = i_owner.call{value: address(this).balance}("");
        if (!success) revert TokenShop__TransferFailed();
    }

    // Getter functions
    function balanceOf(address account) external view returns (uint256) {
        return s_balances[account];
    }

    function totalSupply() external view returns (uint256) {
        return s_totalSupply;
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }

    function getPriceFeed() external view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}