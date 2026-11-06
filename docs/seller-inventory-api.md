# Seller inventory API contract

The Flutter Seller Inventory module uses the configured API base URL and the
following authenticated endpoints. These are client integration contracts; the
repository does not create or alter Supabase tables.

## Authentication and authorization

All routes must require a valid seller access token. The server must derive the
seller identity from the verified token and enforce tenant ownership for every
product. Never trust a seller ID supplied by the mobile client. The current
Flutter foundation does not yet provide a production token provider, so these
requests will be rejected by a correctly secured backend until auth-token
injection is connected.

## List products

`GET /seller/products`

Return either a JSON array or an object containing an `items` or `data` array.
Each product requires `id`, `title`, numeric `price`, and integer `stock`.
Optional fields: `description`, `category`, `sku`, `image_url`,
`sale_price`, and `is_active`.

## Create and update

- `POST /seller/products`
- `PATCH /seller/products/{product_id}`

Both requests use `multipart/form-data`. Text fields are `title`, `price`,
`stock`, `is_active`, and optional `description`, `category`, `sku`,
`sale_price`. An optional image is sent as a multipart file field named
`image`. The server must validate image type/size, store it in a private or
appropriately public product-media bucket, and return stable HTTPS image URLs
from the list endpoint.

## Remove from catalogue

`DELETE /seller/products/{product_id}`

The API should implement this as a soft removal/archive, not a hard delete, so
historical order items and financial records remain intact. The backend must
check tenant ownership and reject removal when business rules require the
product to remain visible for open orders.

## Error handling

Use normal HTTP status codes (400 validation, 401 unauthenticated, 403
unauthorized, 404 not found, 409 business conflict, 5xx server failure) with a
safe user-facing message. Never return payment credentials or private seller
data in product responses.
