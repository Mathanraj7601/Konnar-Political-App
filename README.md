# Konnar Political Party Member Registration System

Full-stack implementation with:
- Flutter mobile app (Android + iOS compatible)
- Node.js + Express backend
- PostgreSQL database with SQL migrations

## Features Delivered

### Flutter App
- Splash screen with party name and dummy member ID card UI
- OTP-based login flow
- OTP verification with 2-minute countdown timer and resend
- Existing user -> direct member card
- New user -> multi-step registration flow
  - Step 1: personal info + DOB picker + auto age
  - Step 2: address info
  - Step 3: success page + auto redirect
- Member card screen with:
  - Party name
  - Member name
  - Member ID
  - Mobile number
  - Address
  - DOB
  - Age
  - QR code
  - Profile image placeholder
- Provider-based state management
- API layer, models, services, reusable widgets

### Backend API
- `POST /auth/send-otp`
- `POST /auth/verify-otp`
- `POST /auth/register`
- `GET /user/profile`
- `GET /user/member-card`
- JWT-protected user routes
- OTP hashed in DB
- OTP expires in 2 minutes
- OTP rate limiting
- SMS service abstraction (Twilio or mock)

### PostgreSQL
- `users` table
- `otp_verification` table
- SQL migration files
- Seed dummy data

## Project Structure

```text
.
+-- backend/
¦   +-- .env.example
¦   +-- API_DOCUMENTATION.md
¦   +-- migrations/
¦   ¦   +-- 001_create_tables.sql
¦   ¦   +-- 002_seed_dummy_data.sql
¦   +-- scripts/
¦   ¦   +-- migrate.js
¦   ¦   +-- seed.js
¦   +-- src/
¦   ¦   +-- app.js
¦   ¦   +-- server.js
¦   ¦   +-- config/
¦   ¦   +-- controllers/
¦   ¦   +-- middleware/
¦   ¦   +-- routes/
¦   ¦   +-- services/
¦   ¦   +-- utils/
¦   +-- package.json
+-- lib/
¦   +-- config/
¦   +-- models/
¦   +-- providers/
¦   +-- screens/
¦   +-- services/
¦   +-- theme/
¦   +-- utils/
¦   +-- widgets/
¦   +-- main.dart
+-- pubspec.yaml
```

## Prerequisites

- Flutter 3.24+
- Dart 3.5+
- Node.js 18+
- PostgreSQL 14+

## Backend Setup

1. Go to backend folder:

```bash
cd backend
```

2. Install dependencies:

```bash
npm install
```

3. Configure environment:

```bash
cp .env.example .env
```

Edit `.env` values (especially `DATABASE_URL`, `JWT_SECRET`, `OTP_SECRET`).

4. Create database:

```sql
CREATE DATABASE konnar_party;
```

5. Run migrations:

```bash
npm run migrate
```

6. (Optional) Re-apply dummy seed data:

```bash
npm run seed
```

7. Start backend server:

```bash
npm run dev
```

Server runs by default at:

`http://localhost:4000`

## Flutter Setup

1. Install Flutter packages from project root:

```bash
flutter pub get
```

2. Run app with backend URL:

Android Emulator example:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:4000
```

iOS Simulator example:

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:4000
```

Physical device example:

```bash
flutter run --dart-define=API_BASE_URL=http://<YOUR_LOCAL_IP>:4000
```

## Dummy Data

Seed migration inserts one existing user:

- Mobile: `9876543210`
- Member ID: `KPP-2026-001000`
- Name: `Arun Kumar`

For OTP in development/mock mode, API returns `debugOtp` in `/auth/send-otp` response.

## Environment Variables (`backend/.env`)

```env
NODE_ENV=development
PORT=4000
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/konnar_party

JWT_SECRET=replace_with_a_long_random_secret
JWT_EXPIRES_IN=7d

OTP_SECRET=replace_with_a_different_long_random_secret
OTP_EXPIRY_MINUTES=2
OTP_RESEND_SECONDS=30
OTP_RATE_LIMIT_WINDOW_MS=900000
OTP_RATE_LIMIT_MAX=5

SMS_PROVIDER=mock
SMS_FROM=KONNAR

TWILIO_ACCOUNT_SID=
TWILIO_AUTH_TOKEN=
TWILIO_FROM_NUMBER=

APP_PARTY_NAME=Konnar Political Party
```

## API Reference

Full endpoint details, payloads, and sample responses:

- See `backend/API_DOCUMENTATION.md`

## Notes

- OTP is never stored in plaintext.
- Registration enforces 18+ age based on DOB.
- Mobile must be OTP-verified before registration.
- Member card data is served from protected backend routes.
