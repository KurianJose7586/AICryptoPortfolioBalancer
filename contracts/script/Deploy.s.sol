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
        
        // Sepolia Uniswap V2 Router address
        address uniswapRouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

        PortfolioManager portfolioManager = new PortfolioManager(uniswapRouter, address(priceOracle));
        console.log("PortfolioManager deployed to:", address(portfolioManager));

        // Add Sepolia testnet token addresses
        address[] memory testTokens = new address[](3);
        string[] memory symbols = new string[](3);

        // Sepolia testnet addresses
        testTokens[0] = 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238; // USDC (Sepolia)
        symbols[0] = "USDC";
        testTokens[1] = 0x7169D38820dfd117C3FA1f22a697dBA58d90BA06; // USDT (Sepolia)
        symbols[1] = "USDT";
        testTokens[2] = 0x68194a729C2450ad26072b3D33ADaCbcef39D574; // DAI (Sepolia)
        symbols[2] = "DAI";

        console.log("Adding supported tokens to PortfolioManager...");
        for (uint256 i = 0; i < testTokens.length; i++) {
            try portfolioManager.addSupportedToken(testTokens[i], symbols[i]) {
                console.log("Added token:", symbols[i], "at", testTokens[i]);
            } catch Error(string memory reason) {
                console.log("Failed to add", symbols[i], ":", reason);
            }
        }

        // Set initial prices in the oracle
        console.log("Setting initial prices in PriceOracle...");
        uint256[] memory initialPrices = new uint256[](3);
        initialPrices[0] = 1e8; // USDC $1
        initialPrices[1] = 1e8; // USDT $1
        initialPrices[2] = 1e8; // DAI $1

        for (uint256 i = 0; i < testTokens.length; i++) {
            try priceOracle.updatePrice(testTokens[i], initialPrices[i]) {
                console.log("Set price for", symbols[i], ":", initialPrices[i]);
            } catch Error(string memory reason) {
                console.log("Failed to set price for", symbols[i], ":", reason);
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
        console.log('  "network": "sepolia"');
        console.log("}");
    }
}
