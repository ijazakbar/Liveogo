# Buyer catalogue and cart API contract

This client increment adds an API-backed product catalogue and server-backed cart. It does not create local demo products or treat a client-side cart as an order.

All endpoints are relative to the configured API base URL and require a valid buyer access token. The server must derive the buyer identity from the token; never accept a buyer ID supplied by the app.

## Catalogue

`GET /buyer/products?page=1&q=optional-search`

Return a JSON array or an object containing an `items` or `data` array. Each product requires:

- `id`, `title`, numeric `price`
- optional `currency` (defaults to PKR), `description`, `seller_name`, `image_url`
- optional non-negative integer `stock_quantity`
- optional boolean `is_available`

Only approved sellers' published products may be returned. The server must enforce publication, location/visibility and inventory rules. Search must be parameterized and rate-limited.

## Cart

### Read cart

`GET /buyer/cart`

Return an object with `items`, server-calculated `subtotal` and `currency`. Each item requires `id`, `product_id`, `title`, `unit_price`, `line_total` and positive integer `quantity`; `image_url` and item `currency` are optional.

### Add item

`POST /buyer/cart/items`

Request: `{ "product_id": "catalogue-product-id", "quantity": 1 }`

The server must re-check product publication, seller approval, stock, price and buyer eligibility at write time. Return the authoritative updated cart or a clear validation/conflict response.

### Change quantity

`PATCH /buyer/cart/items/{cart_item_id}`

Request: `{ "quantity": 2 }`

The server must enforce ownership, stock limits and positive quantities, and return the authoritative updated cart.

### Remove item

`DELETE /buyer/cart/items/{cart_item_id}`

Removal must be scoped to the authenticated buyer's cart.

## Checkout and payments are intentionally not enabled by this increment

Do not create an order from the mobile client or infer a successful payment from a redirect. Before enabling checkout, implement an idempotent server-side order-creation contract that snapshots product title, price, seller and delivery data; revalidates stock and totals; and returns an order ID and server-owned status.

COD acceptance must be recorded by the server. JazzCash and Easypaisa must use merchant-side payment initiation, signed callbacks/webhooks, amount/currency verification, replay protection and reconciliation. The app must never mark an order paid based only on a client response.

No Supabase schema or production data is changed by this client increment.
