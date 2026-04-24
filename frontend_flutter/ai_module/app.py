import json
import traceback
from flask import Flask, request, jsonify
from ai_engine import (
    get_rental_verdict,
    get_true_cost,
    analyze_risks,
    get_negotiation_advice
)

app = Flask(__name__)

@app.route("/", methods=["GET"])
def home():
    return jsonify({"message": "AI Rental Backend Running"})

@app.route("/api/analyze", methods=["POST"])
def analyze():
    try:
        data = request.json or {}

        property_data = data.get("property_data", {})
        market_data = data.get("market_data", {})
        risks_input = data.get("risks_text", "")

        # =========================
        # VALIDATION
        # =========================
        rent = property_data.get("askingRent")
        income = property_data.get("monthlyIncome")

        if rent is None or income is None:
            return jsonify({
                "success": False,
                "error": "Missing askingRent or monthlyIncome"
            }), 400

        if income <= 0:
            return jsonify({
                "success": False,
                "error": "monthlyIncome must be > 0"
            }), 400

        # =========================
        # COMPUTE CORE METRICS
        # =========================
        rent_to_income = rent / income

        computed = {
            "rent_to_income": round(rent_to_income, 2),
            "status":
                "AFFORDABLE" if rent_to_income <= 0.3 else
                "MODERATE" if rent_to_income <= 0.5 else
                "UNAFFORDABLE"
        }

        # =========================
        # AI CALLS (your existing engines)
        # =========================
        verdict = get_rental_verdict(property_data, market_data, {})
        cost = get_true_cost(risks_input)
        risk = analyze_risks(risks_input)

        # =========================
        # NEGOTIATION (OPTIONAL but recommended)
        # =========================
        negotiation = None
        try:
            price = rent
            market_price = market_data.get("avgRent", rent)
            risk_level = risk.get("overall_severity", "MEDIUM")

            negotiation = get_negotiation_advice(
                price,
                market_price,
                risk_level
            )
        except:
            negotiation = None  # don't break system if this fails

        # =========================
        # FINAL RESPONSE
        # =========================
        return jsonify({
            "success": True,
            "data": {
                "verdict": verdict,
                "true_cost": cost,
                "risk": risk,
                "negotiation": negotiation,
                "computed": computed
            }
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