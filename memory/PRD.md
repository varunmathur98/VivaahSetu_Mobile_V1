# VivahSetu - Premium Matrimony Mobile App (PRD)

## Overview
Full-stack mobile matrimony application cloned from vivaahsetu.in built with Expo React Native + FastAPI + MongoDB.

## Complete Feature List

### 1. Authentication
- **Email/Password**: Register + Login with JWT tokens
- **Google Sign-In**: via `expo-auth-session` (works on web + native)
  - First-time Google users → `/google-complete` screen (enter name + gender)
  - Returning Google users → direct login
- Web Client ID: `125166695153-frfr2u1qgvjlh00buou5hb5kcc8e2gfd.apps.googleusercontent.com`

### 2. Profile Management
- 20+ fields (name, DOB, gender, religion, caste, subcaste, education, profession, etc.)
- DOB-based auto age calculation (age field grayed out)
- Photo upload (base64, max 5)
- Photo visibility toggle (yes/no)
- Partner preferences (multi-select religions, caste, state, locations, professions)
- Comprehensive Indian data dropdowns (33 states, 100+ cities, 60+ castes)

### 3. Match Browsing
- Card-based UI with filters (age, religion, caste, city, profession)
- Tappable cards → detailed profile view (`/match/[id]`)
- Photo visibility rules based on connection status + plan
- Contact details gated (upgrade prompt → subscription page)

### 4. Connection System
- Max 5 active connections, 15-day timer
- Send/accept/reject/cancel/remove
- Notifications on connection events
- Profile visitor tracking

### 5. Real-time Chat (WebSocket)
- WebSocket at `/ws/chat/{token}` for real-time messaging
- REST fallback: `POST /api/chat/send`, `GET /api/chat/{partnerId}`
- Requires Focus/Commit plan + active mutual connection
- Read receipts, typing indicators, unread counts
- Message bubbles UI with timestamp

### 6. Subscription Plans (Cashfree Payment)
- Free (Explore): Browse, interests, 5 connections
- Focus ₹699→₹210/mo (70% OFF, MOST POPULAR): Chat, contacts, visitors
- Commit ₹1499→₹450/mo (70% OFF, COMING SOON): Priority, verified badge
- Cashfree production payment integration (order creation, verification, webhook)

### 7. Push Notifications Infrastructure
- FCM token storage endpoint (`POST /api/notifications/register-token`)
- In-app notifications stored per user
- Ready for FCM push when built with EAS

### 8. Navigation
- 5-tab bottom navigation: Home, Browse, Connections, Messages, Profile
- Stack screens: Login, Google Complete, Edit Profile, Match Detail, Chat, Subscription, Settings

## SHA-1 Fingerprint (For Google Sign-In on Production Android)
To generate release SHA-1 for Google Console:
```bash
# Option 1: Via EAS Build
eas credentials --platform android
# Select "Keystore" → view SHA-1

# Option 2: Via keytool (if you have the release keystore)
keytool -list -v -keystore your-release.keystore -alias your-alias
```
Add the SHA-1 to Google Cloud Console → APIs & Services → Credentials → Your Android OAuth Client

## Tech Stack
- Frontend: Expo SDK 54, React Native, expo-router, Zustand, expo-auth-session
- Backend: FastAPI, MongoDB (Motor), JWT, bcrypt, WebSocket
- Payments: Cashfree PG (Production)
- Auth: Email/Password + Google OAuth (expo-auth-session)

## API Endpoints (40+)
Auth (4), Profile (5), Matches (1), Connections (6), Chat (4), Notifications (3), Subscriptions (1), Payments (3), Misc (2)

## MongoDB
- Production: mongodb+srv://VivahSetu:***@cluster0.wstlcdd.mongodb.net/vivahsetu
- Local dev: mongodb://localhost:27017/vivahsetu
