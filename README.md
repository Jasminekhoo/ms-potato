# ms-potato

AI Rent Advisor for UMHackathon 2026.

This repository contains a Node.js backend, a Flutter frontend, and a Python AI module.

## What The App Does

- Lets a user enter a property name, location, asking rent, and monthly income.
- Analyses the rental using backend logic and fallback demo data.
- Shows result cards for verdict, all-in monthly cost, risk, negotiation tips, and source transparency.
- Includes a landlord payment page with tenant tracking, payment summaries, and tenant rating tools.

## Project Structure

- `server.js` - Node.js backend API
- `financial_risk_engine.js` - rental risk engine used by the backend
- `frontend_flutter/` - Flutter app
- `frontend_flutter/ai_module/` - Python AI module

## Requirements

- Node.js
- Flutter SDK
- Python 3
- Chrome browser for Flutter web

## Install Dependencies

### Backend

From the repository root:

```powershell
npm install
```

### Flutter frontend

```powershell
cd frontend_flutter
flutter pub get
```

### Python AI module

```powershell
cd frontend_flutter/ai_module
pip install -r requirements.txt
```

## How To Run

Use three terminals.

### Terminal 1: Backend

From the repository root:

```powershell
npm start
```

The backend runs on:

```text
http://localhost:3001
```

### Terminal 2: Flutter frontend

```powershell
cd frontend_flutter
flutter run -d chrome
```

### Terminal 3: AI module

```powershell
cd frontend_flutter/ai_module
python app.py
```

## Notes

- If you run the frontend before the backend, the app can still show fallback demo data.
- If Chrome is not detected, run `flutter devices` and pick another available target.
- If Flutter web fails to launch, make sure the Flutter SDK is installed and `flutter doctor` is clean.
- On Windows, some Flutter desktop setups may require Developer Mode, but Chrome web does not.

## API Overview

The frontend expects the backend to expose these endpoints.

### `POST /analyse`

Example request:

```json
{
  "propertyName": "Vista Harmoni",
  "location": "Cheras",
  "askingRent": 2200,
  "monthlyIncome": 7000
}
```

Example response:

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

### `POST /compare`

Example request:

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

Example response:

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

## Frontend Routes

- `/` Home
- `/input` Analysis input
- `/result` Analysis result
- `/compare` Comparison page
- `/payments` Payments page
- `/login` Login screen
- `/signup` Signup screen
- `/about` About page

## Troubleshooting

- If `npm start` fails, check whether port `3001` is already in use.
- If Flutter shows a blank page, confirm the backend is running and `flutter run -d chrome` is started from `frontend_flutter`.
- If Python does not start, make sure you are inside `frontend_flutter/ai_module` and that `requirements.txt` is installed.

## License

MIT
