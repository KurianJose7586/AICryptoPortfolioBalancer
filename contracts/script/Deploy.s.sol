// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/PriceOracle.sol";
import "../src/PortfolioManager.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy Price Oracle first
        console.log("Deploying PriceOracle...");
        PriceOracle priceOracle = new PriceOracle();
        console.log("PriceOracle deployed to:", address(priceOracle));

        // Deploy Portfolio Manager
        console.log("Deploying PortfolioManager...");
        
        // For now, we'll use a mock Uniswap router address
        // In production, you'd use the actual Uniswap V2 router address
        address mockUniswapRouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; // Uniswap V2 Router
        
        PortfolioManager portfolioManager = new PortfolioManager(
            mockUniswapRouter,
            address(priceOracle)
        );
        console.log("PortfolioManager deployed to:", address(portfolioManager));

        // Add some common token addresses and their symbols
        address[] memory commonTokens = new address[](5);
        string[] memory symbols = new string[](5);
        
        // Ethereum Mainnet addresses (you'd need to adjust for testnet)
        commonTokens[0] = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; // USDC
        symbols[0] = "USDC";
        commonTokens[1] = 0xdAC17F958D2ee523a2206206994597C13D831ec7; // USDT
        symbols[1] = "USDT";
        commonTokens[2] = 0x6B175474E89094C44Da98b954EedeAC495271d0F; // DAI
        symbols[2] = "DAI";
        commonTokens[3] = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599; // WBTC
        symbols[3] = "WBTC";
        commonTokens[4] = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // WETH
        symbols[4] = "WETH";

        console.log("Adding supported tokens to PortfolioManager...");
        for (uint256 i = 0; i < commonTokens.length; i++) {
            try portfolioManager.addSupportedToken(commonTokens[i], symbols[i]) {
                console.log("Added symbols and commonTokens: ", symbols[i],commonTokens[i]);
            } catch Error(string memory reason) {
                console.log("Failed to add", symbols[i], ":", reason);
            }
        }

        // Set initial prices in the oracle
        console.log("Setting initial prices in PriceOracle...");
        uint256[] memory initialPrices = new uint256[](5);
        initialPrices[0] = 1e8; // USDC $1
        initialPrices[1] = 1e8; // USDT $1
        initialPrices[2] = 1e8; // DAI $1
        initialPrices[3] = 68000e8; // WBTC $68,000
        initialPrices[4] = 3500e8; // WETH $3,500

        for (uint256 i = 0; i < commonTokens.length; i++) {
            try priceOracle.updatePrice(commonTokens[i], initialPrices[i]) {
                console.log("Set price for", commonTokens[i], ":", initialPrices[i]);
            } catch Error(string memory reason) {
                console.log("Failed to set price for", commonTokens[i], ":", reason);
            }
        }

        vm.stopBroadcast();

        console.log("\nDeployment completed successfully!");
        console.log("PriceOracle:", address(priceOracle));
        console.log("PortfolioManager:", address(portfolioManager));
        
        // Export addresses for frontend use
        console.log("\nDeployment info for frontend:");
        console.log("{");
        console.log('  "priceOracle": "', address(priceOracle), '",');
        console.log('  "portfolioManager": "', address(portfolioManager), '",');
        console.log('  "network": "', vm.envString("NETWORK"), '"');
        console.log("}");
    }
} 