# Token Shop

A token marketplace using Chainlink Price Feeds to enable buying and selling tokens at live ETH/USD prices.

## What I Built

- Buy tokens with ETH at real-time USD price
- Sell tokens back for ETH
- Chainlink Price Feed integration for live pricing
- Owner withdrawal functionality
- Full test suite with mock price feeds

## Tech Stack

- Solidity 0.8.19
- Foundry (Forge, Cast, Anvil)
- Chainlink Price Feeds

## How It Works

| Action | Description |
|--------|-------------|
| `buyTokens()` | Send ETH, receive tokens at $1/token based on live ETH price |
| `sellTokens()` | Return tokens, receive ETH at current market rate |
| `getEthPriceUsd()` | Fetches live ETH/USD price from Chainlink |
| `getTokenAmount()` | Calculate how many tokens for given ETH amount |

## Example

If ETH = $2000:
- Send 1 ETH → Receive 2000 SHOP tokens
- Sell 1000 SHOP → Receive 0.5 ETH

## Usage

### Build
```bash
forge build
```

### Test
```bash
forge test
```

### Deploy (Local)
```bash
# Terminal 1
anvil

# Terminal 2
forge script script/DeployTokenShop.s.sol:DeployTokenShop --rpc-url http://127.0.0.1:8545 --private-key <PRIVATE_KEY> --broadcast
```

### Interact
```bash
# Buy tokens with 0.1 ETH
cast send <CONTRACT> "buyTokens()" --value 0.1ether --rpc-url http://localhost:8545 --private-key <KEY>

# Check token balance
cast call <CONTRACT> "balanceOf(address)" <WALLET> --rpc-url http://localhost:8545

# Check ETH price
cast call <CONTRACT> "getEthPriceUsd()" --rpc-url http://localhost:8545

# Sell tokens
cast send <CONTRACT> "sellTokens(uint256)" 1000000000000000000000 --rpc-url http://localhost:8545 --private-key <KEY>
```

## Testing

Uses `MockV3Aggregator` to simulate Chainlink price feeds locally. This allows testing price-dependent logic without connecting to real oracles.
```bash
forge test -vvv
```

## Chainlink Integration

- **Price Feed**: AggregatorV3Interface
- **Sepolia ETH/USD**: `0x694AA1769357215DE4FAC081bf1f309aDC325306`
- **Decimals**: Chainlink returns 8 decimals, scaled to 18 in contract

## Lessons Learned

- Chainlink Price Feeds for real-world data
- Mock contracts for local testing
- Decimal handling (8 → 18 conversion)
- Two-way token economics (buy/sell)

## Author

Neo Maredi