import traceback
import json
from flask import Flask, request, jsonify
from ai_engine import (
    get_rental_verdict,
    get_true_cost,
    analyze_risks,
    get_negotiation_advice
)
import traceback
import logging

logging.basicConfig(level=logging.DEBUG)
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
    print("✅ /api/verdict HIT")
    try:
        data = request.get_json(silent=True) or {}

        property_data = data.get("property_data", {})
        market_data = data.get("market_data", {})
        risks = data.get("risks", {})

        # =========================
        # 1. VALIDATION
        # =========================
        rent = property_data.get("askingRent")
        income = property_data.get("monthlyIncome")

        if rent is None or income is None:
            return jsonify({
                "success": False,
                "error": "Missing rent or income"
            }), 400

        if income <= 0:
            return jsonify({
                "success": False,
                "error": "Income must be > 0"
            }), 400

        # =========================
        # 2. CALCULATE RATIO
        # =========================
        ratio = rent / income

        # =========================
        # 3. CALL AI
        # =========================
        ai_result = get_rental_verdict(property_data, market_data, risks)

        # (Make sure AI result is parsed JSON if it's a string)
        if isinstance(ai_result, str):
            try:
                ai_result = json.loads(ai_result)
            except:
                ai_result = {"raw": ai_result}

        # =========================
        # 4. HARD OVERRIDE LOGIC
        # =========================
        if ratio > 0.5:
            ai_result["warning"] = "High rent-to-income ratio"
        ai_result["risk_override"] = True

        # Optional: attach affordability info
        ai_result["affordability"] = {
            "ratio": round(ratio, 2),
            "status": (
                "AFFORDABLE" if ratio <= 0.3 else
                "MODERATE" if ratio <= 0.5 else
                "UNAFFORDABLE"
            )
        }

        return jsonify({
            "success": True,
            "data": ai_result
        })

    except Exception as e:
        print("❌ VERDICT ERROR:")
        traceback.print_exc()
    return jsonify({
        "success": False,
        "error": str(e),
        "trace": traceback.format_exc()
    }), 500


# ==============================
# 2. TRUE COST
# ==============================
@app.route("/api/true-cost", methods=["POST"])
def true_cost():
    print("✅ /api/true-cost HIT")
    try:
        data = request.get_json(silent=True) or {}

        listing_text = data.get("listing_text")  # ✅ FIX

        if not listing_text:
            return jsonify({
                "success": False,
                "error": "listing_text is required"
            }), 400

        result = get_true_cost(listing_text)

        return jsonify({
            "success": True,
            "data": result
        })

    except Exception as e:
        print("❌ TRUE COST ERROR:")
        traceback.print_exc()
    return jsonify({
        "success": False,
        "error": str(e),
        "trace": traceback.format_exc()
    }), 500


# ==============================
# 3. RISK RADAR
# ==============================
@app.route("/api/risk", methods=["POST"])
def risk_analysis():
    print("✅ /api/risk HIT")
    try:
        data = request.get_json(silent=True) or {}

        text_data = data.get("text_data")  # ✅ FIX

        if not text_data:
            return jsonify({
                "success": False,
                "error": "text_data is required"
            }), 400

        result = analyze_risks(text_data)

        return jsonify({
            "success": True,
            "data": result
        })

    except Exception as e:
        print("❌ RISK ERROR:")
        traceback.print_exc()
    return jsonify({
        "success": False,
        "error": str(e),
        "trace": traceback.format_exc()
    }), 500


# ==============================
# 4. NEGOTIATION COACH
# ==============================
@app.route("/api/negotiation", methods=["POST"])
def negotiation():
    print("✅ /api/negotiation HIT")
    try:
        data = request.get_json(silent=True) or {}

        price = data.get("price")
        market_price = data.get("market_price")
        risk = data.get("risk")

        result = get_negotiation_advice(price, market_price, risk)

        return jsonify({
            "success": True,
            "data": result
        })

    except Exception as e:
        print("❌ NEGOTIATION ERROR:")
        traceback.print_exc()
    return jsonify({
        "success": False,
        "error": str(e),
        "trace": traceback.format_exc()
    }), 500


# ==============================
# RUN SERVER
# ==============================
if __name__ == "__main__":
    app.run(debug=True, port=5000)