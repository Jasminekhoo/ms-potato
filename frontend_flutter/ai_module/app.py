import traceback
from flask import Flask, request, jsonify
from ai_engine import (
    get_rental_verdict,
    get_true_cost,
    analyze_risks,
    get_negotiation_advice
)

app = Flask(__name__)


# ==============================
# HEALTH CHECK
# ==============================
@app.route("/", methods=["GET"])
def home():
    return jsonify({"message": "AI Rental Backend Running"})


# ==============================
# 1. RENTAL VERDICT
# ==============================
@app.route("/api/verdict", methods=["POST"])
def rental_verdict():
    try:
        data = request.json

        property_data = data.get("property_data")
        market_data = data.get("market_data")
        risks = data.get("risks")

        result = get_rental_verdict(property_data, market_data, risks)

        return jsonify({
            "success": True,
            "data": result
        })

    except Exception as e:
        return jsonify({
            "success": False,
            "error": str(e)
        }), 500


# ==============================
# 2. TRUE COST
# ==============================
@app.route("/api/true-cost", methods=["POST"])
def true_cost():
    try:
        data = request.json
        listing_text = data.get("listing_text")

        result = get_true_cost(listing_text)

        return jsonify({
            "success": True,
            "data": result
        })

    except Exception as e:
        return jsonify({
            "success": False,
            "error": str(e)
        }), 500


# ==============================
# 3. RISK RADAR
# ==============================
@app.route("/api/risk", methods=["POST"])
def risk_analysis():
    try:
        data = request.json
        text_data = data.get("text_data")

        result = analyze_risks(text_data)

        return jsonify({
            "success": True,
            "data": result
        })

    except Exception as e:
        return jsonify({
            "success": False,
            "error": str(e)
        }), 500


# ==============================
# 4. NEGOTIATION COACH
# ==============================
@app.route("/api/negotiation", methods=["POST"])
def negotiation():
    try:
        data = request.json

        price = data.get("price")
        market_price = data.get("market_price")
        risk = data.get("risk")

        result = get_negotiation_advice(price, market_price, risk)

        return jsonify({
            "success": True,
            "data": result
        })

    except Exception as e:
        return jsonify({
            "success": False,
            "error": str(e)
        }), 500


# ==============================
# RUN SERVER
# ==============================
if __name__ == "__main__":
    app.run(debug=True, port=5000)