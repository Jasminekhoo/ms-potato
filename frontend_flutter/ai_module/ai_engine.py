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

# ==============================
# MASTER SYSTEM PROMPT
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

    # remove markdown
    text = re.sub(r"```json|```", "", text).strip()

    # extract JSON block
    start = text.find("{")
    end = text.rfind("}")

    if start == -1 or end == -1:
        raise ValueError(f"No JSON found: {text}")

    return text[start:end + 1]

# ==============================
# CORE GLM CALL
# ==============================
def call_glm(user_prompt, retry=False):
    if not API_KEY:
        raise Exception("Missing ILMU_API_KEY")

    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {API_KEY}"
    }

    data = {
        "model": MODEL,
        "max_tokens": 2000,   # FIX: prevent truncation
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
        # ==============================
        # AUTO RECOVERY (DO NOT CHANGE LOGIC)
        # ==============================
        if retry:
            raise Exception(f"Failed JSON after retry: {cleaned}")

        retry_prompt = user_prompt + "\n\nIMPORTANT: Return SHORTER and COMPLETE valid JSON only."

        return call_glm(retry_prompt, retry=True)

# ==============================
# 1. RENTAL VERDICT ENGINE
# ==============================
def get_rental_verdict(property_data, market_data, risks):
    prompt = f"""
Property Data:
{json.dumps(property_data, indent=2)}

Market Data:
{json.dumps(market_data, indent=2)}

Risk Signals:
{json.dumps(risks, indent=2)}

Task:
Evaluate if this rental is a GOOD deal.

Scoring Logic:
- Price vs market (40%)
- Risk level (30%)
- Affordability/value (30%)

IMPORTANT:
- Return ONLY valid JSON
- No markdown
- No incomplete fields
- Keep each field under 2 sentences

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
# 2. TRUE COST CALCULATOR
# ==============================
def get_true_cost(listing_text):
    prompt = f"""
Listing Text:
\"\"\"
{listing_text}
\"\"\"

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

# ==============================
# 3. RISK RADAR
# ==============================
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

# ==============================
# 4. NEGOTIATION COACH
# ==============================
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