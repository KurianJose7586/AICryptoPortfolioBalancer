
```bash
# Navigate back to root directory
cd ..

# Serve the frontend
python -m http.server 8000
```

Open `http://localhost:8000` in your browser.

## Usage

1. Connect Wallet: Click "Connect Wallet" and approve the connection
2. Enter Intent: Describe your rebalancing goals (e.g., "I want to be more defensive due to market volatility")
3. Generate Strategy: Click "Generate AI Strategy" to get an optimized portfolio allocation
4. Review Strategy: Check the AI-generated strategy details and reasoning
5. Execute: Click "Execute Strategy" to deploy the strategy on-chain
6. Monitor: View your portfolio and strategy history

## Example Intents

- "I want to rebalance my portfolio to be more defensive due to market volatility, focusing on stablecoins and blue-chip tokens"
- "Optimize my portfolio for maximum growth potential with moderate risk tolerance"
- "Create a balanced portfolio with 60% growth assets and 40% stable assets"
- "Rebalance to capitalize on current DeFi opportunities while maintaining some safety"

## Technical Details

### Smart Contract Functions

- `createStrategy()`: Create a new rebalancing strategy
- `executeStrategy()`: Execute a stored strategy
- `getUserStrategies()`: Retrieve user's strategy history
- `calculatePortfolioValue()`: Calculate total portfolio value
- `getTokenValue()`: Get value of specific token holdings

### Frontend Features

- Responsive Design: Works on desktop and mobile
- Real-time Updates: Live portfolio and strategy updates
- Error Handling: Graceful error handling and user feedback
- Wallet Integration: Seamless Web3 wallet connection

## Security Considerations

- Always verify contract addresses before interacting
- Review strategies before execution
- Use hardware wallets for large transactions
- Keep private keys secure

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

MIT License - see LICENSE file for details 