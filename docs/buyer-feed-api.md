# Buyer feed API contract

The Flutter Buyer feed reads from `GET /buyer/feed` relative to the configured API base URL.

## Request
- `tab`: `live`, `following`, or `for_you`
- `page`: 1-based page number (client currently requests page 1)
- `q`: optional search term reserved for a later search increment

## Response
Return a JSON array or an object containing an `items` or `data` array.

Each item requires `id` and `seller_name`. Optional fields: `type`, `caption`, `seller_handle`, `poster_url`, `media_url`, `is_live`, `viewer_count`, and `pinned_product`.

A pinned product contains `id`, `title`, numeric `price`, optional `currency` (defaults to PKR), and optional `image_url`.

Example response shape (illustrative contract only; not production data):

```json
{
  "items": [{
    "id": "feed-item-id",
    "type": "live",
    "seller_name": "Verified shop name",
    "seller_handle": "shop-handle",
    "caption": "Seller-provided stream description",
    "poster_url": "https://cdn.example.com/poster.jpg",
    "media_url": "https://stream.example.com/stream-id",
    "is_live": true,
    "viewer_count": 0,
    "pinned_product": {
      "id": "catalogue-product-id",
      "title": "Seller catalogue title",
      "price": 1250,
      "currency": "PKR"
    }
  }]
}
```

## Integration and safety
- Configure `API_BASE_URL`, e.g. `https://api.example.com/api/v1`.
- The endpoint must enforce authentication, visibility, moderation and following permissions server-side.
- This increment renders poster images and feed metadata only. Actual HLS/WebRTC playback, chat, likes, follows, comments and purchase actions need authenticated API contracts and media SDK integration.
- No Supabase schema or production data is changed by this client increment.
