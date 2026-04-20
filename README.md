# ms-potato

UMHackathon 2026

# AI Rent Advisor

Frontend scaffold for Member 2 is ready under `frontend_flutter`.

## What is implemented (Member 2 deliverables)

- Input form screen
  - `property name`, `location`, `asking rent`, `monthly income`
- Result dashboard
  - Verdict card
  - True all-in cost breakdown card
  - Risk radar card
  - Negotiation coach card
- Loading state
  - Animated skeleton placeholders while waiting
- Static WOW pages
  - Buy vs Rent mocked page
  - Comparison mocked page (3 curated cards)

## Frontend Routes

- `/` Home
- `/input` Analysis input
- `/result` Analysis result
- `/compare` Mock comparison page
- `/buy-vs-rent` Mock buy vs rent page
- `/login` Login scaffold
- `/signup` Signup scaffold

## API Contract expected from backend

### POST /analyse

Request:

```json
{
  "propertyName": "Vista Harmoni",
  "location": "Cheras",
  "askingRent": 2200,
  "monthlyIncome": 7000
}
```

Response:

```json
{
  "verdict": "ACCEPTABLE",
  "explanation": "Plain language summary",
  "listedRent": 2200,
  "trueCostMonthly": 2520,
  "hiddenCosts": {
    "Parking": 180,
    "Utilities Deposit (amortized)": 70,
    "Access Card + Setup": 40,
    "Internet Setup": 30
  },
  "riskScore": 5.9,
  "riskSummary": "Pattern summary from complaints",
  "negotiationTips": ["Tip 1", "Tip 2", "Tip 3"]
}
```

### POST /compare

Request:

```json
{
  "properties": [
    {
      "propertyName": "A",
      "location": "Cheras",
      "askingRent": 2200,
      "monthlyIncome": 7000
    }
  ]
}
```

Response:

```json
{
  "items": [
    {
      "name": "A",
      "location": "Cheras",
      "verdict": "ACCEPTABLE",
      "trueCostMonthly": 2320,
      "riskScore": 5.8
    }
  ]
}
```

## Run

1. Install Flutter SDK
2. In `frontend_flutter`, run:
   - `flutter pub get`
   - `flutter run -d chrome`

## Notes

- If backend is down or slow (>8s), frontend uses mocked fallback responses for demo continuity.
- API base URL is set in `frontend_flutter/lib/constants/config.dart`.
