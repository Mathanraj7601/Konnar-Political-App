# Demo Mode (No Backend / No DB)

The app can run fully offline using a mock API layer.

## Default behavior

- `USE_MOCK_BACKEND` defaults to `true`
- No Node.js server, PostgreSQL, or SMS service is required
- All key screens are demo-ready:
  - Login
  - OTP verification
  - New-user registration (personal info + address)
  - Registration success
  - Member card

## Run

```bash
flutter run
```

## Demo credentials

- Existing user mobile: `1234512345`
- OTP: `123456`
- New user path: enter any other valid 10-digit mobile number

## Switch back to real backend

```bash
flutter run --dart-define=USE_MOCK_BACKEND=false --dart-define=API_BASE_URL=http://10.0.2.2:4000
```
