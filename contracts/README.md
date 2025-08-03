# 🧠 AI Crypto Portfolio Rebalancer - Web3 Edition

A decentralized AI-powered crypto portfolio rebalancer that generates investment strategies using Gemini AI and executes them on-chain using smart contracts.

## 🚀 Features

### AI-Powered Strategy Generation
- **Gemini AI Integration**: Uses Google's Gemini API to analyze portfolios and generate intelligent rebalancing strategies
- **Multiple Strategy Types**: Aggressive Growth, Balanced, Conservative, DeFi Focus, AI & Big Data Focus
- **Real-time Analysis**: Portfolio risk assessment and investment rationale

### On-Chain Execution
- **Smart Contract Integration**: Deploy and execute strategies using Solidity smart contracts
- **Web3 Wallet Support**: MetaMask integration for secure transactions
- **Real-time Price Feeds**: Oracle-based price data for accurate valuations
- **Automated Rebalancing**: Execute buy/sell orders through DEX integration

### User Experience
- **Modern UI**: Beautiful glassmorphism design with Tailwind CSS
- **Real-time Visualization**: Before/after portfolio charts using Chart.js
- **Transaction Tracking**: Monitor strategy execution on the blockchain
- **Responsive Design**: Works on desktop and mobile devices

## 🏗️ Architecture

### Smart Contracts
- **PortfolioManager.sol**: Main contract for strategy creation and execution
- **PriceOracle.sol**: Price feed contract for real-time token valuations
- **Integration**: Uniswap V2 router for DEX trading

### Frontend
- **Web3 Integration**: Ethers.js for blockchain interaction
- **AI Strategy Processing**: Convert AI recommendations to smart contract calls
- **Wallet Management**: MetaMask connection and transaction signing

## 🛠️ Setup & Installation

### Prerequisites
- [Foundry](https://getfoundry.sh/) - Ethereum development framework
- [Node.js](https://nodejs.org/) (for frontend)
- MetaMask browser extension

### 1. Clone and Setup
```bash
git clone <repository-url>
cd AICryptoPortfolioBalancer/contracts
forge install
```

### 2. Install Dependencies
```bash
# Install OpenZeppelin contracts
forge install OpenZeppelin/openzeppelin-contracts
```

### 3. Environment Setup
Create a `.env` file in the contracts directory:
```env
PRIVATE_KEY=your_private_key_here
MAINNET_RPC_URL=your_mainnet_rpc_url
SEPOLIA_RPC_URL=your_sepolia_rpc_url
ETHERSCAN_API_KEY=your_etherscan_api_key
NETWORK=sepolia
```

### 4. Compile Contracts
```bash
forge build
```

### 5. Run Tests
```bash
forge test
```

### 6. Deploy Contracts
```bash
# Deploy to local network
forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --broadcast

# Deploy to Sepolia testnet
forge script script/Deploy.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast --verify
```

### 7. Update Frontend Configuration
After deployment, update the contract addresses in `script.js`:
```javascript
const contractAddresses = {
    portfolioManager: '0x...', // Your deployed address
    priceOracle: '0x...'       // Your deployed address
};
```

### 8. Run Frontend
```bash
# From the root directory
python -m http.server 8000
# or
npx serve .
```

## 📋 Usage

### 1. Connect Wallet
- Click "🔗 Connect Wallet" to connect MetaMask
- Ensure you're on the correct network (Sepolia for testing)

### 2. Input Portfolio
- Enter your current holdings in format: `1.5 BTC, 10 ETH, 5000 USDC`
- Supported tokens: BTC, ETH, USDC, USDT, DAI, and more

### 3. Generate Strategy
- Select a strategy type from the dropdown
- Click "✨ Generate Intent" for AI-generated investment intent
- Or write your own custom intent

### 4. Analyze & Rebalance
- Click "Analyze & Rebalance" to generate AI analysis
- Review the proposed rebalancing plan
- View before/after portfolio visualizations

### 5. Execute On-Chain
- Click "🚀 Execute Strategy" to deploy strategy to blockchain
- Confirm transaction in MetaMask
- Monitor execution on blockchain explorer

## 🔧 Configuration

### Supported Networks
- **Local Development**: `http://localhost:8545`
- **Sepolia Testnet**: `https://sepolia.infura.io/v3/YOUR_KEY`
- **Ethereum Mainnet**: `https://mainnet.infura.io/v3/YOUR_KEY`

### Token Configuration
Update token addresses in `web3Integration.js`:
```javascript
const tokenMap = {
    'BTC': '0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599', // WBTC
    'ETH': '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2', // WETH
    // Add more tokens...
};
```

### AI Configuration
Set your Gemini API key in the environment or update the API call in `script.js`.

## 🧪 Testing

### Smart Contract Tests
```bash
# Run all tests
forge test

# Run specific test
forge test --match-test testCreateStrategy

# Run with verbose output
forge test -vvv
```

### Frontend Testing
- Test wallet connection with MetaMask
- Verify strategy creation and execution
- Check transaction confirmation on blockchain explorer

## 🔒 Security

### Smart Contract Security
- **Access Control**: Only owner can pause/unpause contracts
- **Reentrancy Protection**: Uses OpenZeppelin's ReentrancyGuard
- **Input Validation**: Comprehensive parameter validation
- **Emergency Functions**: Owner can withdraw funds if needed

### Frontend Security
- **Wallet Validation**: Verify wallet connection before transactions
- **Transaction Confirmation**: User must confirm all blockchain transactions
- **Error Handling**: Comprehensive error handling and user feedback

## 📊 Monitoring

### Blockchain Events
Monitor these events for strategy execution:
- `StrategyCreated`: New strategy deployed
- `StrategyExecuted`: Strategy executed on-chain
- `RebalanceExecuted`: Individual buy/sell transactions

### Transaction Tracking
- All transactions are logged with hashes
- View transaction details on blockchain explorer
- Monitor gas costs and execution status

## 🚨 Important Notes

### Disclaimer
This tool is for educational and illustrative purposes only. It does not provide financial advice. All investment decisions should be made with the consultation of a qualified financial advisor.

### Gas Costs
- Strategy creation: ~100,000 gas
- Strategy execution: ~200,000-500,000 gas (varies by complexity)
- Ensure sufficient ETH for gas fees

### Network Considerations
- Test thoroughly on Sepolia before mainnet
- Monitor gas prices for optimal execution
- Consider using gas estimation before transactions

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## 📄 License

MIT License - see LICENSE file for details

## 🆘 Support

For issues and questions:
- Create an issue on GitHub
- Check the documentation
- Review the test files for examples

---

**Built with ❤️ using Foundry, Ethers.js, and Gemini AI**
