# Phone OTP API contract

The Flutter client uses the backend as the authority for phone verification and session issuance. An OTP request is **not** a successful sign-in.

## Request an OTP

`POST /auth/phone/otp/request`

Request JSON: `{ "phone_number": "+923001234567" }`

Success JSON: `{ "challenge_id": "opaque-server-id", "expires_in": 300 }`

The server must normalize and rate-limit phone numbers, use a verified SMS provider, prevent enumeration, enforce resend cooldowns, and return a generic safe response where appropriate.

## Verify an OTP

`POST /auth/phone/otp/verify`

Request JSON: `{ "phone_number": "+923001234567", "challenge_id": "opaque-server-id", "code": "123456" }`

Success JSON: `{ "access_token": "short-lived-token", "refresh_token": "rotating-refresh-token" }`

Only the server may verify OTPs and issue tokens. Enforce expiry, one-time use, attempt limits, replay protection, device/session policy and audit logging. Never log OTP values or return them to the client.

## Remaining integration

The Flutter UI/repository contract does not configure an SMS vendor or create backend endpoints. The backend must implement these routes and token refresh/revocation before this flow can be considered operational. Tokens must be stored using platform secure storage and attached to authenticated API calls; no service-role or provider secret belongs in the app.
