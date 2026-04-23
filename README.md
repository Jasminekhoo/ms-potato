# ms-potato

UMHackathon 2026

# AI Rent Advisor

Frontend scaffold for Member 2 is ready under `frontend_flutter`.

## What is implemented

- Input form screen
  - `property name`, `location`, `asking rent`, `monthly income`
- Result dashboard
  - Verdict card
  - True all-in cost breakdown card
  - Risk radar card
  - Negotiation coach card
- Loading state
  - Animated skeleton placeholders while waiting
- Comparison page
  - Side-by-side comparison cards for rent-focused decision making

## Frontend Routes

- `/` Home
- `/input` Analysis input
- `/result` Analysis result
- `/compare` Comparison page
- `/login` Login scaffold
- `/signup` Signup scaffold
- `/about` About page

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

Run the app from the `frontend_flutter` folder:

```powershell
cd "C:\Users\user\OneDrive\Desktop\ms-potato_umh\frontend_flutter"
flutter pub get
flutter run -d windows
```

If you want to open it in Chrome instead, use:

```powershell
cd "C:\Users\user\OneDrive\Desktop\ms-potato_umh\frontend_flutter"
flutter pub get
flutter run -d chrome
```

If `chrome` is not available, check your devices with:

```powershell
flutter devices
```

If you are running the project for the first time on Windows, make sure Developer Mode is enabled in Windows settings so Flutter can create desktop symlinks.

1. Install Flutter SDK
2. Open the project in VS Code or Terminal
3. Run the commands above from `frontend_flutter`

## Notes

- If backend is down or slow (>8s), frontend uses mocked fallback responses for demo continuity.
- API base URL is set in `frontend_flutter/lib/constants/config.dart`.
