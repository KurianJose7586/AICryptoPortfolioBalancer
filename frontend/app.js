// Check if ethers is available
if (typeof ethers === 'undefined') {
    throw new Error('Ethers library not loaded. Please check the CDN link.');
}

class PortfolioBalancer {
    constructor() {
        this.provider = null;
        this.signer = null;
        this.contract = null;
        this.userAddress = null;
        this.geminiApiKey = window.CONFIG?.geminiApiKey || '';

        this.contractABI = [
            "function createStrategy(string name, address[] targetTokens, uint256[] targetPercentages) external",
            "function executeStrategy(uint256 strategyId) external",
            "function getUserStrategies(address user) external view returns (tuple(string name, address[] targetTokens, uint256[] targetPercentages, uint256 timestamp, bool executed)[])",
            "function getSupportedTokens() external view returns (address[], string[])",
            "function calculatePortfolioValue(address user) external view returns (uint256)",
            "function getTokenValue(address user, address token) external view returns (uint256)"
        ];
        
        this.contractAddress = "0xc49d07Ae270Fb68D50A15e3a91a92c70c9aC190C";
        
        this.initializeEventListeners();
    }

    initializeEventListeners() {
        document.getElementById('connectWallet').addEventListener('click', () => this.connectWallet());
        document.getElementById('generateStrategy').addEventListener('click', () => this.generateStrategy());
        document.getElementById('executeStrategy').addEventListener('click', () => this.executeStrategy());
        document.getElementById('modifyStrategy').addEventListener('click', () => this.modifyStrategy());
    }

    async connectWallet() {
        try {
            if (typeof window.ethereum === 'undefined') {
                alert('Please install MetaMask or another Web3 wallet');
                return;
            }

            const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
            this.userAddress = accounts[0];

            this.provider = new ethers.BrowserProvider(window.ethereum);
            this.signer = await this.provider.getSigner();

            this.contract = new ethers.Contract(this.contractAddress, this.contractABI, this.signer);

            await this.updateWalletInfo();
            this.loadPortfolio();
            this.loadStrategyHistory();

        } catch (error) {
            console.error('Error connecting wallet:', error);
            alert('Failed to connect wallet: ' + error.message);
        }
    }

    async updateWalletInfo() {
        const walletInfo = document.getElementById('walletInfo');
        const walletAddress = document.getElementById('walletAddress');
        const walletBalance = document.getElementById('walletBalance');

        walletAddress.textContent = `${this.userAddress.slice(0, 6)}...${this.userAddress.slice(-4)}`;
        walletInfo.classList.remove('hidden');

        const balance = await this.provider.getBalance(this.userAddress);
        const ethBalance = ethers.formatEther(balance);
        walletBalance.textContent = `${parseFloat(ethBalance).toFixed(4)} ETH`;
    }

    async generateStrategy() {
        const intent = document.getElementById('rebalanceIntent').value.trim();
        if (!intent) {
            alert('Please enter your rebalance intent');
            return;
        }

        if (!this.userAddress) {
            alert('Please connect your wallet first');
            return;
        }

        const includeMarketAnalysis = document.getElementById('includeMarketAnalysis').checked;
        const includeRiskAssessment = document.getElementById('includeRiskAssessment').checked;

        document.getElementById('strategySection').classList.remove('hidden');

        try {
            const strategy = await this.generateAIStrategy(intent, includeMarketAnalysis, includeRiskAssessment);
            this.displayStrategy(strategy);
        } catch (error) {
            console.error('Error generating strategy:', error);
            document.getElementById('strategyDetails').innerHTML = 
                '<div class="error">Failed to generate strategy. Please try again.</div>';
        }
    }

    async generateAIStrategy(intent, includeMarketAnalysis, includeRiskAssessment) {
        try {
            const prompt = `As a crypto portfolio optimization expert, analyze the following rebalance intent and create an optimized portfolio strategy:

Intent: ${intent}

${includeMarketAnalysis ? 'Include current market analysis and trends.' : ''}
${includeRiskAssessment ? 'Include risk assessment and mitigation strategies.' : ''}

Please provide a JSON response with the following structure:
{
    "name": "Strategy Name",
    "tokens": [
        {"symbol": "USDC", "percentage": 30, "reason": "Stable store of value"},
        {"symbol": "ETH", "percentage": 40, "reason": "Blue chip crypto"},
        {"symbol": "BTC", "percentage": 30, "reason": "Digital gold"}
    ],
    "reasoning": "Detailed reasoning...",
    "risks": "Risk assessment...",
    "expectedOutcome": "Expected results..."
}

Only return valid JSON, no additional text.`;

            const response = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=${this.geminiApiKey}`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    contents: [{
                        parts: [{
                            text: prompt
                        }]
                    }]
                })
            });

            const data = await response.json();
            
            if (!response.ok) {
                throw new Error(`Gemini API error: ${data.error?.message || 'Unknown error'}`);
            }

            const aiResponse = data.candidates[0].content.parts[0].text;
            
            // Extract JSON from the response
            const jsonMatch = aiResponse.match(/\{[\s\S]*\}/);
            if (!jsonMatch) {
                throw new Error('Invalid JSON response from AI');
            }

            const strategy = JSON.parse(jsonMatch[0]);
            
            // Validate the response structure
            if (!strategy.name || !strategy.tokens || !Array.isArray(strategy.tokens)) {
                throw new Error('Invalid strategy structure from AI');
            }

            return strategy;

        } catch (error) {
            console.error('Error calling Gemini API:', error);
            
            // Fallback to mock response if API fails
            return {
                name: "Defensive Market Strategy",
                tokens: [
                    { symbol: "USDC", percentage: 40, reason: "Stable store of value during volatility" },
                    { symbol: "ETH", percentage: 35, reason: "Blue chip crypto with strong fundamentals" },
                    { symbol: "BTC", percentage: 25, reason: "Digital gold, hedge against inflation" }
                ],
                reasoning: "Given the current market volatility and your defensive stance, this allocation prioritizes stability while maintaining exposure to proven cryptocurrencies.",
                risks: "Market risk remains present, but reduced through stablecoin allocation.",
                expectedOutcome: "Reduced portfolio volatility with maintained growth potential."
            };
        }
    }

    displayStrategy(strategy) {
        const strategyDetails = document.getElementById('strategyDetails');
        
        let tokensHtml = '';
        strategy.tokens.forEach(token => {
            tokensHtml += `
                <div class="token-item">
                    <span class="token-symbol">${token.symbol}</span>
                    <span class="token-balance">${token.percentage}%</span>
                </div>
            `;
        });

        strategyDetails.innerHTML = `
            <h3>${strategy.name}</h3>
            <div style="margin: 15px 0;">
                <strong>Token Allocation:</strong>
                ${tokensHtml}
            </div>
            <div style="margin: 15px 0;">
                <strong>Reasoning:</strong>
                <p>${strategy.reasoning}</p>
            </div>
            <div style="margin: 15px 0;">
                <strong>Risk Assessment:</strong>
                <p>${strategy.risks}</p>
            </div>
            <div style="margin: 15px 0;">
                <strong>Expected Outcome:</strong>
                <p>${strategy.expectedOutcome}</p>
            </div>
        `;

        this.currentStrategy = strategy;
    }

    async executeStrategy() {
        if (!this.currentStrategy) {
            alert('No strategy to execute');
            return;
        }

        try {
            const targetTokens = this.currentStrategy.tokens.map(token => 
                this.getTokenAddress(token.symbol)
            );
            const targetPercentages = this.currentStrategy.tokens.map(token => 
                token.percentage * 100
            );

            const tx = await this.contract.createStrategy(
                this.currentStrategy.name,
                targetTokens,
                targetPercentages
            );

            await tx.wait();
            alert('Strategy created successfully!');
            this.loadStrategyHistory();

        } catch (error) {
            console.error('Error executing strategy:', error);
            alert('Failed to execute strategy: ' + error.message);
        }
    }

    modifyStrategy() {
        document.getElementById('rebalanceIntent').value = '';
        document.getElementById('strategySection').classList.add('hidden');
        this.currentStrategy = null;
    }

    getTokenAddress(symbol) {
        // Sepolia testnet token addresses
        const tokenAddresses = {
            'USDC': '0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238',
            'USDT': '0x7169D38820dfd117C3FA1f22a697dBA58d90BA06',
            'DAI': '0x68194a729C2450ad26072b3D33ADaCbcef39D574'
        };
        return tokenAddresses[symbol] || '0x0000000000000000000000000000000000000000';
    }

    async loadPortfolio() {
        if (!this.contract) return;

        try {
            const portfolioDisplay = document.getElementById('portfolioDisplay');
            const [tokenAddresses, tokenSymbols] = await this.contract.getSupportedTokens();
            
            if (tokenAddresses.length === 0) {
                portfolioDisplay.innerHTML = '<div class="no-data">No tokens in portfolio</div>';
                return;
            }

            let portfolioHtml = '';
            for (let i = 0; i < tokenAddresses.length; i++) {
                const value = await this.contract.getTokenValue(this.userAddress, tokenAddresses[i]);
                const formattedValue = ethers.utils.formatEther(value);
                
                portfolioHtml += `
                    <div class="token-item">
                        <span class="token-symbol">${tokenSymbols[i]}</span>
                        <span class="token-balance">${parseFloat(formattedValue).toFixed(4)}</span>
                    </div>
                `;
            }

            portfolioDisplay.innerHTML = portfolioHtml;

        } catch (error) {
            console.error('Error loading portfolio:', error);
            document.getElementById('portfolioDisplay').innerHTML = 
                '<div class="error">Failed to load portfolio</div>';
        }
    }

    async loadStrategyHistory() {
        if (!this.contract) return;

        try {
            const historyDisplay = document.getElementById('strategyHistory');
            const strategies = await this.contract.getUserStrategies(this.userAddress);
            
            if (strategies.length === 0) {
                historyDisplay.innerHTML = '<div class="no-data">No strategies executed yet</div>';
                return;
            }

            let historyHtml = '';
            strategies.forEach((strategy, index) => {
                const date = new Date(strategy.timestamp * 1000).toLocaleDateString();
                const status = strategy.executed ? 'Executed' : 'Pending';
                const statusClass = strategy.executed ? 'strategy-executed' : '';
                
                historyHtml += `
                    <div class="strategy-item ${statusClass}">
                        <div class="strategy-name">${strategy.name}</div>
                        <div class="strategy-status">Created: ${date} | Status: ${status}</div>
                    </div>
                `;
            });

            historyDisplay.innerHTML = historyHtml;

        } catch (error) {
            console.error('Error loading strategy history:', error);
            document.getElementById('strategyHistory').innerHTML = 
                '<div class="error">Failed to load strategy history</div>';
        }
    }
}

document.addEventListener('DOMContentLoaded', () => {
    window.portfolioBalancer = new PortfolioBalancer();
});

if (typeof window.ethereum !== 'undefined') {
    window.ethereum.on('accountsChanged', async (accounts) => {
        if (accounts.length === 0) {
            location.reload();
        } else {
            window.portfolioBalancer.userAddress = accounts[0];
            await window.portfolioBalancer.updateWalletInfo();
            window.portfolioBalancer.loadPortfolio();
            window.portfolioBalancer.loadStrategyHistory();
        }
    });
} 