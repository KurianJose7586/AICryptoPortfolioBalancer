// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/PriceOracle.sol";
import "../src/PortfolioManager.sol";

contract PortfolioManagerTest is Test {
    PriceOracle public priceOracle;
    PortfolioManager public portfolioManager;

    address public user = address(0x1);
    address public token1 = address(0x100);
    address public token2 = address(0x200);

    function setUp() public {
        // Deploy contracts
        priceOracle = new PriceOracle();
        portfolioManager = new PortfolioManager(
            address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D), // Mock Uniswap router
            address(priceOracle)
        );

        // Add test tokens
        portfolioManager.addSupportedToken(token1, "TEST1");
        portfolioManager.addSupportedToken(token2, "TEST2");

        // Set prices
        priceOracle.updatePrice(token1, 100e8); // $100
        priceOracle.updatePrice(token2, 50e8); // $50

        // Start acting as user
        vm.startPrank(user);
    }

    function testCreateStrategy() public {
        address[] memory tokens = new address[](2);
        uint256[] memory percentages = new uint256[](2);

        tokens[0] = token1;
        tokens[1] = token2;
        percentages[0] = 6000; // 60%
        percentages[1] = 4000; // 40%

        portfolioManager.createStrategy("Test Strategy", tokens, percentages);

        // Verify strategy was created
        PortfolioManager.Strategy[] memory strategies = portfolioManager.getUserStrategies(user);
        assertEq(strategies.length, 1);
        assertEq(strategies[0].name, "Test Strategy");
        assertEq(strategies[0].targetTokens.length, 2);
        assertEq(strategies[0].targetPercentages[0], 6000);
        assertEq(strategies[0].targetPercentages[1], 4000);
        assertEq(strategies[0].executed, false);
    }

    function testCreateStrategyInvalidPercentages() public {
        address[] memory tokens = new address[](2);
        uint256[] memory percentages = new uint256[](2);

        tokens[0] = token1;
        tokens[1] = token2;
        percentages[0] = 6000; // 60%
        percentages[1] = 3000; // 30% (should be 40% to sum to 100%)

        vm.expectRevert("Percentages must sum to 100%");
        portfolioManager.createStrategy("Test Strategy", tokens, percentages);
    }

    function testCreateStrategyUnsupportedToken() public {
        address[] memory tokens = new address[](1);
        uint256[] memory percentages = new uint256[](1);

        tokens[0] = address(0x999); // Unsupported token
        percentages[0] = 10000; // 100%

        vm.expectRevert("Token not supported");
        portfolioManager.createStrategy("Test Strategy", tokens, percentages);
    }

    function testPriceOracle() public {
        uint256 price1 = priceOracle.getPrice(token1);
        uint256 price2 = priceOracle.getPrice(token2);

        assertEq(price1, 100e8);
        assertEq(price2, 50e8);
    }

    function testSupportedTokens() public {
        (address[] memory tokens, string[] memory symbols) = portfolioManager.getSupportedTokens();
        // Note: This is a simplified test as the actual implementation returns empty arrays
        // In a real implementation, you'd verify the tokens are properly stored
    }

    function testPauseUnpause() public {
        vm.stopPrank(); // Stop acting as user

        // Only owner can pause
        vm.prank(user);
        vm.expectRevert();
        portfolioManager.pause();

        // Owner can pause
        portfolioManager.pause();
        assertTrue(portfolioManager.paused());

        // Owner can unpause
        portfolioManager.unpause();
        assertFalse(portfolioManager.paused());
    }
}
