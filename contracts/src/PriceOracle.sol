// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";

contract PriceOracle is Ownable {
    mapping(address => uint256) public tokenPrices;
    mapping(address => uint256) public lastUpdateTime;

    uint256 public constant PRICE_PRECISION = 1e8; // 8 decimal places
    uint256 public constant UPDATE_THRESHOLD = 300; // 5 minutes

    event PriceUpdated(address token, uint256 price, uint256 timestamp);

    constructor() Ownable(msg.sender) {}

    modifier onlyValidToken(address token) {
        require(token != address(0), "Invalid token address");
        _;
    }

    function updatePrice(address token, uint256 price) external onlyOwner onlyValidToken(token) {
        require(price > 0, "Price must be greater than 0");
        tokenPrices[token] = price;
        lastUpdateTime[token] = block.timestamp;
        emit PriceUpdated(token, price, block.timestamp);
    }

    function updateMultiplePrices(address[] calldata tokens, uint256[] calldata prices) external onlyOwner {
        require(tokens.length == prices.length, "Arrays length mismatch");
        for (uint256 i = 0; i < tokens.length; i++) {
            require(tokens[i] != address(0), "Invalid token address");
            require(prices[i] > 0, "Price must be greater than 0");
            tokenPrices[tokens[i]] = prices[i];
            lastUpdateTime[tokens[i]] = block.timestamp;
            emit PriceUpdated(tokens[i], prices[i], block.timestamp);
        }
    }

    function getPrice(address token) public view onlyValidToken(token) returns (uint256) {
        require(tokenPrices[token] > 0, "Price not available");
        require(block.timestamp - lastUpdateTime[token] <= UPDATE_THRESHOLD, "Price too old");
        return tokenPrices[token];
    }

    function getPriceUSD(address token) external view onlyValidToken(token) returns (uint256) {
        return getPrice(token);
    }

    function isPriceValid(address token) external view returns (bool) {
        if (tokenPrices[token] == 0) return false;
        if (block.timestamp - lastUpdateTime[token] > UPDATE_THRESHOLD) return false;
        return true;
    }
}
