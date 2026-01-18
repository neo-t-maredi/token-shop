// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title MockV3Aggregator
 * @author Neo Maredi
 * @notice Fake Chainlink price feed for local testing
 * @dev Mimics AggregatorV3Interface so we can test without real Chainlink
 *      In production, this would be a real Chainlink oracle on mainnet/testnet
 *      For local Anvil testing, we use this mock to control the price
 */
contract MockV3Aggregator {
    // How many decimals the price has (Chainlink ETH/USD uses 8)
    uint8 public decimals;
    
    // The current price answer
    int256 public answer;

    constructor(uint8 _decimals, int256 _initialAnswer) {
        decimals = _decimals;
        answer = _initialAnswer;
    }

    // Mimics Chainlink's latestRoundData - returns the fake price
    function latestRoundData() external view returns (
        uint80 roundId,
        int256 _answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    ) {
        return (0, answer, 0, 0, 0);
    }

    // Lets us change the price during tests to simulate market movement
    function updateAnswer(int256 _answer) external {
        answer = _answer;
    }
}