# LiveOgo

LiveOgo is a Flutter-first live-commerce platform for buyers, sellers and platform administrators.

## Stack

- Flutter + Material 3
- Riverpod for state management
- GoRouter for navigation
- Dio for API networking
- Google Fonts (Inter)

## Getting started

1. Install Flutter stable and run `flutter doctor`.
2. From this directory run `flutter pub get`.
3. Configure the API base URL with `--dart-define=API_BASE_URL=https://your-api.example`.
4. Run `flutter run`.
5. Run checks with `dart format lib test`, `flutter analyze`, and `flutter test`.

## Current client implementation

- App foundation: splash/onboarding, server-driven Pakistani phone OTP request and verification screens, role selection and buyer/seller navigation.
- Authentication client: OTP challenge/verification repository, secure access/refresh token storage, and bearer-token attachment to non-auth API calls. The backend must still implement the documented OTP routes, SMS delivery, token refresh and revocation.
- Buyer LIVE feed: Live/Following/For You tabs, vertical poster/feed paging, seller metadata, pinned product detail and loading/empty/error/retry states. The current feed renders media metadata/posters; it does not yet play a real HLS/WebRTC stream.
- Buyer commerce: searchable API-backed catalogue, server-backed cart read/add/quantity update/removal, server-calculated subtotal, loading/empty/error states, and model tests. Checkout remains disabled until an order and payment backend is implemented and verified.
- Seller inventory: API-backed catalogue listing, local search, low-stock indicators, add/edit forms, image selection/upload, active status and confirmed catalogue removal.
- Backend contracts: `docs/phone-otp-api.md`, `docs/buyer-feed-api.md`, `docs/buyer-commerce-api.md`, and `docs/seller-inventory-api.md`.

## Required backend work before production

The Flutter client depends on authenticated API endpoints. The repository documents contracts but does not, by itself, prove that those routes are deployed or that SMS, streaming, chat, payment, delivery, KYC or admin services are configured.

Before launch, implement and test the server-side endpoints with tenant/role authorization, validation, rate limits, audit logs and safe error responses. The server must be authoritative for product prices, stock, cart totals, order state and payment verification. JazzCash/Easypaisa require signed merchant callbacks/webhooks and reconciliation; COD acceptance must also be recorded server-side.

Do not enable checkout based on client-side calculations or redirects. Do not represent feed posters as live video playback. No mock transactions or fake OTP success are used by this client.

No Supabase schema or production data is modified by these Flutter client increments. Do not place service-role keys, payment secrets or SMS provider credentials in the app or repository.

## Project structure

- `lib/app`: app configuration, routing and theme
- `lib/core`: networking and shared UI
- `lib/features/auth`: onboarding, sign-in and role selection
- `lib/features/buyer`: feed, catalogue and cart
- `lib/features/seller`: seller studio, inventory models, API repository and UI
- `docs`: backend integration contracts
- `test`: model and feature tests
