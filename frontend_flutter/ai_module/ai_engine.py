import requests
import json
import os
import re
from dotenv import load_dotenv

load_dotenv()

# ==============================
# CONFIG
# ==============================
ILMU_API_URL = "https://api.ilmu.ai/v1/chat/completions"
API_KEY = os.getenv("ILMU_API_KEY")
MODEL = os.getenv("MODEL")

if not API_KEY:
    raise Exception("Missing ILMU_API_KEY")

if not MODEL:
    raise Exception("Missing MODEL")

# ==============================
# MASTER SYSTEM PROMPT (UNCHANGED)
# ==============================
SYSTEM_PROMPT = """
You are a Malaysian property analysis AI.

You must:
- Use simple, clear Malaysian English
- Be practical, not theoretical
- Sound like a smart local advisor (not robotic)
- Consider Malaysian rental norms (deposit, maintenance, MRT, etc.)

Rules:
- Be concise but insightful
- No fluff
- No generic advice
- Always justify decisions with real reasoning
"""

# ==============================
# JSON CLEANER
# ==============================
def clean_json_response(text):
    if not text:
        raise ValueError("Empty response from model")

    text = re.sub(r"```json|```", "", text).strip()

    start = text.find("{")
    end = text.rfind("}")

    if start == -1 or end == -1:
        raise ValueError(f"No JSON found: {text}")

    return text[start:end + 1]

# ==============================
# CORE GLM CALL (SAFE)
# ==============================
def call_glm(user_prompt, retry=False):
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {API_KEY}"
    }

    data = {
        "model": MODEL,
        "max_tokens": 2000,
        "temperature": 0.2,
        "messages": [
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": user_prompt}
        ]
    }

    response = requests.post(
        ILMU_API_URL,
        headers=headers,
        json=data,
        timeout=30
    )

    if response.status_code != 200:
        raise Exception(f"GLM API Error: {response.text}")

    result = response.json()

    if "choices" not in result:
        raise Exception(f"Invalid response: {result}")

    raw_output = result["choices"][0]["message"]["content"]
    cleaned = clean_json_response(raw_output)

    try:
        return json.loads(cleaned)

    except json.JSONDecodeError:
        if retry:
            raise Exception(f"Failed JSON after retry: {cleaned}")

        retry_prompt = user_prompt + "\n\nIMPORTANT: Return SHORTER and COMPLETE valid JSON only."
        return call_glm(retry_prompt, retry=True)

# ==============================
# 1. RENTAL VERDICT ENGINE (FIXED ONLY)
# ==============================
def get_rental_verdict(property_data, market_data, risks):
    rent = property_data.get("askingRent")

    income = property_data.get("monthlyIncome")

    # 🔥 CRITICAL FIX: do NOT fake missing income
    if rent is None or income is None:
        raise ValueError("Missing askingRent or monthlyIncome")

    if income <= 0:
        raise ValueError("monthlyIncome must be > 0")

    rent_to_income = rent / income

    prompt = f"""
Property Data:
{json.dumps(property_data, indent=2)}

Market Data:
{json.dumps(market_data, indent=2)}

Risk Signals:
{json.dumps(risks, indent=2)}

Computed Affordability (USE THIS, DO NOT RECALCULATE):
- rent_to_income = {rent_to_income:.2f}
- percentage = {rent_to_income * 100:.0f}%

Task:
Evaluate if this rental is a GOOD deal.

Affordability Rule (CRITICAL):
- rent_to_income is already provided above

STRICT DECISION RULES:
- If rent_to_income > 0.5 → verdict MUST be "AVOID"
- If rent_to_income between 0.3–0.5 → MAX verdict is "ACCEPTABLE"
- If rent_to_income <= 0.3 → can be "GREAT DEAL"

Scoring Logic:
- Price vs market (40%)
- Risk level (30%)
- Affordability (30%)

IMPORTANT:
- DO NOT recalculate rent_to_income
- You MUST use the provided value
- You MUST follow STRICT DECISION RULES (no exceptions)
- If rules conflict with scoring, RULES OVERRIDE scoring
- Mention the percentage in value_analysis
- Return ONLY valid JSON
- No markdown
- No extra text

{{
  "verdict": "GREAT DEAL | ACCEPTABLE | AVOID",
  "price_analysis": "...",
  "risk_analysis": "...",
  "value_analysis": "...",
  "final_reason": "2-3 sentence explanation"
}}
"""
    return call_glm(prompt)

# ==============================
# 2–4 (UNCHANGED LOGIC)
# ==============================
def get_true_cost(listing_text):
    prompt = f"""
Listing Text:
\"\"\"{listing_text}\"\"\"

Task:
Extract ALL possible costs and estimate monthly spending.

IMPORTANT:
- Return ONLY valid JSON
- No markdown
- No incomplete JSON

{{
  "base_rent": "...",
  "hidden_costs": [
    {{"type": "deposit", "estimate": "..."}},
    {{"type": "maintenance", "estimate": "..."}},
    {{"type": "parking", "estimate": "..."}}
  ],
  "estimated_total_monthly": "...",
  "notes": "short explanation"
}}
"""
    return call_glm(prompt)


def analyze_risks(text_data):
    prompt = f"""
Text Data:
{text_data}

Task:
Detect real risks and summarize.

IMPORTANT:
- Return ONLY valid JSON
- No markdown

{{
  "top_issues": [
    {{"issue": "...", "category": "...", "frequency": "low|medium|high"}}
  ],
  "overall_severity": "LOW | MEDIUM | HIGH",
  "summary": "clear warning"
}}
"""
    return call_glm(prompt)


def get_negotiation_advice(price, market_price, risk):
    prompt = f"""
Input:
- Asking Price: RM {price}
- Market Price: RM {market_price}
- Risk Level: {risk}

Task:
Give negotiation strategy.

IMPORTANT:
- Return ONLY valid JSON
- No markdown

{{
  "target_price": "...",
  "strategy": [
    "...",
    "...",
    "..."
  ],
  "message": "WhatsApp message to landlord"
}}
"""
    return call_glm(prompt)