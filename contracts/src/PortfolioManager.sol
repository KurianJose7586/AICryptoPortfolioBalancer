// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {IUniswapV2Router} from "./interfaces/IUniswapV2Router.sol";
import {IPriceOracle} from "./interfaces/IPriceOracle.sol";

contract PortfolioManager is Ownable, ReentrancyGuard, Pausable {
    IUniswapV2Router public immutable uniswapRouter;
    IPriceOracle public priceOracle;

    // Supported tokens mapping
    mapping(address => bool) public supportedTokens;
    mapping(address => string) public tokenSymbols;

    // User portfolio tracking
    mapping(address => mapping(address => uint256)) public userBalances;
    mapping(address => uint256) public userTotalValue;

    // Strategy execution tracking
    struct Strategy {
        string name;
        address[] targetTokens;
        uint256[] targetPercentages;
        uint256 timestamp;
        bool executed;
    }

    mapping(address => Strategy[]) public userStrategies;

    // Events
    event TokenAdded(address token, string symbol);
    event TokenRemoved(address token);
    event StrategyCreated(address user, string strategyName, uint256 strategyId);
    event StrategyExecuted(address user, uint256 strategyId);
    event RebalanceExecuted(address user, address token, uint256 amount, bool isBuy);

    constructor(address _uniswapRouter, address _priceOracle) Ownable(msg.sender) {
        uniswapRouter = IUniswapV2Router(_uniswapRouter);
        priceOracle = IPriceOracle(_priceOracle);
    }

    modifier onlySupportedToken(address token) {
        require(supportedTokens[token], "Token not supported");
        _;
    }

    // Admin functions
    function addSupportedToken(address token, string memory symbol) external onlyOwner {
        supportedTokens[token] = true;
        tokenSymbols[token] = symbol;
        emit TokenAdded(token, symbol);
    }

    function removeSupportedToken(address token) external onlyOwner {
        supportedTokens[token] = false;
        delete tokenSymbols[token];
        emit TokenRemoved(token);
    }

    function setPriceOracle(address _priceOracle) external onlyOwner {
        priceOracle = IPriceOracle(_priceOracle);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    // User functions
    function createStrategy(string memory name, address[] memory targetTokens, uint256[] memory targetPercentages)
        external
        whenNotPaused
    {
        require(targetTokens.length == targetPercentages.length, "Arrays length mismatch");
        require(targetTokens.length > 0, "Empty strategy");

        uint256 totalPercentage = 0;
        for (uint256 i = 0; i < targetPercentages.length; i++) {
            require(supportedTokens[targetTokens[i]], "Token not supported");
            totalPercentage += targetPercentages[i];
        }
        require(totalPercentage == 10000, "Percentages must sum to 100%");

        Strategy memory newStrategy = Strategy({
            name: name,
            targetTokens: targetTokens,
            targetPercentages: targetPercentages,
            timestamp: block.timestamp,
            executed: false
        });

        userStrategies[msg.sender].push(newStrategy);
        emit StrategyCreated(msg.sender, name, userStrategies[msg.sender].length - 1);
    }

    function executeStrategy(uint256 strategyId) external nonReentrant whenNotPaused {
        require(strategyId < userStrategies[msg.sender].length, "Strategy not found");
        Strategy storage strategy = userStrategies[msg.sender][strategyId];
        require(!strategy.executed, "Strategy already executed");

        // Calculate current portfolio value
        uint256 totalValue = calculatePortfolioValue(msg.sender);
        require(totalValue > 0, "No portfolio value");

        // Execute rebalancing trades
        for (uint256 i = 0; i < strategy.targetTokens.length; i++) {
            address token = strategy.targetTokens[i];
            uint256 targetValue = (totalValue * strategy.targetPercentages[i]) / 10000;
            uint256 currentValue = getTokenValue(msg.sender, token);

            if (targetValue > currentValue) {
                // Need to buy more
                uint256 buyAmount = targetValue - currentValue;
                executeBuy(msg.sender, token, buyAmount);
            } else if (currentValue > targetValue) {
                // Need to sell
                uint256 sellAmount = currentValue - targetValue;
                executeSell(msg.sender, token, sellAmount);
            }
        }

        strategy.executed = true;
        emit StrategyExecuted(msg.sender, strategyId);
    }

    function executeBuy(address user, address token, uint256 targetValue) internal {
        // This is a simplified implementation
        // In a real scenario, you'd need to handle slippage, gas costs, etc.
        uint256 tokenPrice = priceOracle.getPrice(token);
        uint256 tokenAmount = (targetValue * 1e18) / tokenPrice;

        // Transfer tokens to user (in real implementation, this would be a swap)
        IERC20(token).transfer(user, tokenAmount);
        userBalances[user][token] += tokenAmount;

        emit RebalanceExecuted(user, token, tokenAmount, true);
    }

    function executeSell(address user, address token, uint256 targetValue) internal {
        uint256 tokenPrice = priceOracle.getPrice(token);
        uint256 tokenAmount = (targetValue * 1e18) / tokenPrice;

        require(userBalances[user][token] >= tokenAmount, "Insufficient balance");

        // Transfer tokens from user (in real implementation, this would be a swap)
        IERC20(token).transferFrom(user, address(this), tokenAmount);
        userBalances[user][token] -= tokenAmount;

        emit RebalanceExecuted(user, token, tokenAmount, false);
    }

    function calculatePortfolioValue(address user) public view returns (uint256) {
        uint256 totalValue = 0;
        // This would iterate through all supported tokens
        // For simplicity, we'll return a placeholder
        return userTotalValue[user];
    }

    function getTokenValue(address user, address token) public view returns (uint256) {
        uint256 balance = userBalances[user][token];
        uint256 price = priceOracle.getPrice(token);
        return (balance * price) / 1e18;
    }

    function getUserStrategies(address user) external view returns (Strategy[] memory) {
        return userStrategies[user];
    }

    function getSupportedTokens() external view returns (address[] memory, string[] memory) {
        // This would return all supported tokens
        // For simplicity, returning empty arrays
        address[] memory tokens = new address[](0);
        string[] memory symbols = new string[](0);
        return (tokens, symbols);
    }

    // Emergency functions
    function emergencyWithdraw(address token) external onlyOwner {
        uint256 balance = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(owner(), balance);
    }

    receive() external payable {
        // Allow contract to receive ETH
    }
}
