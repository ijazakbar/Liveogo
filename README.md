# LiveOgo

LiveOgo is a Flutter-first live-commerce SaaS platform for buyers, sellers and platform administrators.

## Stack
- Flutter + Material 3
- Riverpod for state management
- GoRouter for navigation
- Dio for API networking
- Google Fonts (Inter)

## Getting started
1. Install Flutter stable and run `flutter doctor`.
2. From this directory run `flutter pub get`.
3. Configure your API base URL with `--dart-define=API_BASE_URL=https://your-api.example`.
4. Run `flutter run`.
5. Run checks with `dart format lib test`, `flutter analyze`, and `flutter test`.

## Current implementation
- App foundation: theme, splash/onboarding, phone sign-in entry, role selection and buyer/seller navigation.
- Buyer feed: Riverpod/Dio feed loading, Live/Following/For You tabs, vertical feed paging, seller metadata, pinned product detail and loading/empty/error/retry states.
- Seller inventory: API-backed catalogue listing, local search, low-stock indicators, add/edit forms, image selection/upload, active status and confirmed catalogue removal.
- API contracts are documented in `docs/buyer-feed-api.md` and `docs/seller-inventory-api.md`.

The Buyer feed and Seller inventory require corresponding backend endpoints. The current Flutter foundation does not yet attach a production access token to Dio requests, so secured endpoints will reject requests until authentication-token injection is implemented. This client code does not modify the Supabase schema or production data.

Production integrations (Firebase phone OTP, Supabase persistence, Agora live video, Firestore chat, payment provider verification, maps and KYC) require project credentials and backend contracts. They are intentionally not simulated as successful transactions.

## Project structure
- `lib/app`: app configuration, routing and theme
- `lib/core`: networking and shared UI
- `lib/features/auth`: onboarding, sign-in and role selection
- `lib/features/buyer`: buyer navigation and discovery feed
- `lib/features/seller`: seller studio, inventory models, API repository and UI
- `docs`: backend integration contracts
- `test`: model and feature tests
