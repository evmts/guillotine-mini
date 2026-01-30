# Genesis Worker

This Cloudflare Worker proxies compressed genesis files from the OP Superchain registry.
It keeps genesis JSON off any frontend bundle by serving it through a backend endpoint.

## Endpoints

- `GET /genesis?chain=base`
- `GET /genesis?chain=base-sepolia`
- `GET /genesis/base`
- `GET /genesis/base-sepolia`

Responses are `application/zstd` and include `x-genesis-encoding: zstd`.

## Local Dev

```bash
cd cloudflare
wrangler dev
```

## Deploy

```bash
cd cloudflare
wrangler deploy
```
