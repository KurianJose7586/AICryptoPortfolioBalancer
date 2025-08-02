# 🧠 AI Crypto Portfolio Rebalancer

This is a web-based application that leverages the power of the **Gemini large language model** to provide intelligent, AI-driven analysis and rebalancing suggestions for your cryptocurrency portfolio. Users can input their current holdings and define their investment intent, and the AI will generate a comprehensive rebalancing plan, complete with portfolio analysis, transaction steps, and data visualizations.

---

## ✨ Features

- **AI-Generated Investment Intent**  
  Users can select a high-level investment strategy (e.g., _"Aggressive Growth," "DeFi Focus"_) and the AI will generate a clear, concise investment intent.

- **In-Depth Portfolio Analysis**  
  The application provides a detailed analysis of the user's current portfolio, including a summary, a risk assessment, and a rationale for the proposed changes.

- **Intelligent Rebalancing Plan**  
  Based on the user's portfolio and intent, the AI creates a detailed rebalancing plan with specific **BUY**, **SELL**, and **HOLD** actions and target allocations.

- **AI-Explained Transactions**  
  Each simulated on-chain transaction is explained in simple, user-friendly language by the AI, clarifying the purpose of each step.

- **Before & After Visualization**  
  The application displays doughnut charts to visualize the portfolio's composition **before** and **after** the proposed rebalancing.

- **Sleek, Modern UI**  
  A clean, responsive interface built with **Tailwind CSS**, featuring a _glassmorphism_ design.

---

## 🚀 How It Works

1. **Enter Your Portfolio**  
   List your current cryptocurrency holdings in a comma-separated format (e.g., `1.5 BTC, 10 ETH, 5000 ADA`).

2. **Define Your Intent**  
   - **Option A (AI-Generated):** Choose a strategy from the dropdown and click **"✨ Generate Intent"**.  
   - **Option B (Manual):** Write your own investment goals in the text area.

3. **Analyze & Rebalance**  
   Click the **"Analyze & Rebalance"** button.

4. **Review the AI Plan**  
   The application will display the AI's analysis, the proposed rebalancing plan, visualizations, and an explanation of the simulated on-chain steps.

---

## 🛠️ Setup and Running the Application

This project is a single, self-contained HTML file and requires no complex setup.

- **Get the Code:** Save the entire HTML code from the Canvas into a file named `index.html`.
- **Open in a Browser:** Open the `index.html` file in any modern web browser (like Chrome, Firefox, or Edge).
- **No API Key Needed:**  
  The application is designed to work within an environment where the Gemini API key is automatically provided. When running locally, the API calls will not have a key, but the UI and all non-API functionality will still work perfectly for development and testing purposes.

---

## 💻 Technologies Used

- **Frontend:** HTML, Tailwind CSS  
- **JavaScript:** Vanilla JavaScript (ES6+), Chart.js for visualizations  
- **AI/LLM:** Google Gemini API (specifically `gemini-2.5-flash-preview-05-20`)

---

> **Disclaimer:**  
> This tool is for educational and illustrative purposes only. It does not provide financial advice. All investment decisions should be made with the consultation of a qualified financial advisor.
