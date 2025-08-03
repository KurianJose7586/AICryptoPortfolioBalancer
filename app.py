from flask import Flask, render_template, request, jsonify
from dotenv import load_dotenv
import os
import requests

app = Flask(__name__)
load_dotenv()

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
GEMINI_MODEL = "gemini-2.5-flash-preview-05-20"
GEMINI_URL = f"https://generativelanguage.googleapis.com/v1beta/models/{GEMINI_MODEL}:generateContent?key={GEMINI_API_KEY}"

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/generate_intent', methods=['POST'])
def generate_intent():
    data = request.json
    strategy = data.get('strategy')

    prompt = f"""
    Generate a concise, 2-3 sentence investment intent for a crypto portfolio with a strategy of "{strategy}". The tone should be clear and direct.
    """

    schema = {
        "type": "OBJECT",
        "properties": {
            "intent": {"type": "STRING"}
        }
    }

    try:
        response = call_gemini(prompt, schema)
        return jsonify(response)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/rebalance', methods=['POST'])
def rebalance():
    data = request.json
    portfolio = data.get('portfolio')
    intent = data.get('intent')
    market_prices = data.get('market_prices')

    prompt = f"""
    You are an expert crypto portfolio analyst. Your task is to analyze a user's portfolio, compare it to their intent, and generate a detailed rebalancing plan.

    **Context:**
    - User's Portfolio: {portfolio}
    - User's Intent: {intent}
    - Current Market Prices (USD): {market_prices}

    **Instructions:**
    1. **Analysis:** Provide a detailed analysis covering:
        - A one-sentence summary of the current portfolio.
        - The portfolio's risk level (e.g., High, Medium, Low) with a brief justification.
        - A summary of the proposed changes and how they align with the user's intent.
    2. **Plan:** Create a rebalancing plan. The percentages in the plan must represent the *target* allocation of the *total portfolio value* after rebalancing. The sum of all target percentages must equal 100.
    3. Only use assets from the provided market prices list.

    Your response MUST be a valid JSON
