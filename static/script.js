// static/script.js

document.addEventListener('DOMContentLoaded', () => {
    const rebalanceBtn = document.getElementById('rebalance-btn');
    const generateIntentBtn = document.getElementById('generate-intent-btn');
    const portfolioInput = document.getElementById('portfolio-input');
    const intentInput = document.getElementById('intent-input');
    const strategySelector = document.getElementById('strategy-selector');
    const outputSection = document.getElementById('output-section');
    const aiAnalysis = document.getElementById('ai-analysis');
    const rebalancingPlan = document.getElementById('rebalancing-plan');
    const onchainSimulation = document.getElementById('onchain-simulation');
    const loadingSpinner = document.getElementById('loading-spinner');
    const buttonText = document.getElementById('button-text');

    const mockCryptoPrices = {
        'BTC': 68000, 'ETH': 3500, 'SOL': 150, 'ADA': 0.45, 'AVAX': 35,
        'DOT': 7, 'LINK': 18, 'MATIC': 0.7, 'XRP': 0.5, 'DOGE': 0.15,
        'USDC': 1, 'USDT': 1, 'DAI': 1, 'RNDR': 10, 'TAO': 400, 'FET': 2.2,
        'AAVE': 90, 'UNI': 10, 'LDO': 2.3
    };

    generateIntentBtn.addEventListener('click', async () => {
        const strategy = strategySelector.value;
        generateIntentBtn.disabled = true;
        generateIntentBtn.innerHTML = 'Generating...';
        try {
            const res = await fetch('/generate_intent', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ strategy })
            });
            const data = await res.json();
            intentInput.value = data.intent || 'Intent generation failed.';
        } catch (e) {
            intentInput.value = 'Error generating intent.';
        } finally {
            generateIntentBtn.disabled = false;
            generateIntentBtn.innerHTML = '✨ Generate Intent';
        }
    });

    rebalanceBtn.addEventListener('click', async () => {
        const portfolio = portfolioInput.value.trim();
        const intent = intentInput.value.trim();
        if (!portfolio || !intent) return alert('Portfolio and intent are required.');

        loadingSpinner.classList.remove('hidden');
        buttonText.textContent = 'Analyzing...';

        try {
            const res = await fetch('/rebalance', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ portfolio, intent, market_prices: mockCryptoPrices })
            });
            const { analysis, plan } = await res.json();
            outputSection.classList.remove('hidden');
            displayResults(analysis, plan, portfolio);
        } catch (e) {
            alert('Rebalancing failed.');
        } finally {
            loadingSpinner.classList.add('hidden');
            buttonText.textContent = 'Analyze & Rebalance';
        }
    });

    function displayResults(analysis, plan, portfolioText) {
        aiAnalysis.innerHTML = `
            <p><strong>Summary:</strong> ${analysis.summary}</p>
            <p><strong>Risk:</strong> ${analysis.risk}</p>
            <p><strong>Rationale:</strong> ${analysis.rationale}</p>
        `;

        rebalancingPlan.innerHTML = '';
        onchainSimulation.innerHTML = '';

        const before = parsePortfolio(portfolioText);
        const totalValue = Object.entries(before).reduce((sum, [asset, amt]) => sum + amt * (mockCryptoPrices[asset] || 0), 0);
        const beforePortfolio = formatPortfolio(before);
        const afterPortfolio = {};

        plan.forEach(({ action, asset, percentage }) => {
            afterPortfolio[asset] = { value: totalValue * (percentage / 100) };
            const div = document.createElement('div');
            div.className = 'flex justify-between items-center bg-gray-800 p-3 rounded-lg';
            div.innerHTML = `<div><span class="font-bold ${action === 'BUY' ? 'text-green-400' : action === 'SELL' ? 'text-red-400' : 'text-yellow-400'} w-16">${action}</span> ${asset}</div><span class="text-gray-300">Target: ${percentage}%</span>`;
            rebalancingPlan.appendChild(div);
        });

        renderCharts(beforePortfolio, afterPortfolio);
    }

    function parsePortfolio(text) {
        const entries = text.split(',').map(e => e.trim().split(' '));
        return Object.fromEntries(entries.filter(e => e.length === 2).map(([amt, token]) => [token.toUpperCase(), parseFloat(amt)]));
    }

    function formatPortfolio(holdings) {
        const result = {};
        for (const [asset, amt] of Object.entries(holdings)) {
            result[asset] = { value: amt * (mockCryptoPrices[asset] || 0) };
        }
        return result;
    }

    function renderCharts(before, after) {
        const ctx1 = document.getElementById('before-chart').getContext('2d');
        const ctx2 = document.getElementById('after-chart').getContext('2d');
        if (window.beforeChart) window.beforeChart.destroy();
        if (window.afterChart) window.afterChart.destroy();

        const createConfig = (data) => ({
            type: 'doughnut',
            data: {
                labels: Object.keys(data),
                datasets: [{
                    data: Object.values(data).map(d => d.value),
                    backgroundColor: ['#6366F1', '#8B5CF6', '#EC4899', '#F59E0B', '#10B981', '#3B82F6', '#EF4444', '#6B7280', '#F97316', '#0EA5E9'],
                    borderColor: '#1F2937',
                    borderWidth: 2,
                }]
            },
            options: {
                plugins: { legend: { display: false } },
                responsive: true,
                maintainAspectRatio: false
            }
        });

        window.beforeChart = new Chart(ctx1, createConfig(before));
        window.afterChart = new Chart(ctx2, createConfig(after));
    }
});
