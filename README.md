# openproject-railway

Public entry point for a scaled [OpenProject](https://www.openproject.org/)
deployment on [Railway](https://railway.com).

Everything else in the stack runs from upstream's published images
(`openproject/openproject`, `openproject/hocuspocus`, managed Postgres, managed
Redis, managed object storage). Only this one piece needs a repo, because it is
a config file rather than an environment variable.

## Why a proxy at all

OpenProject 17 serves real-time collaborative editing from a separate
[Hocuspocus](https://tiptap.dev/docs/hocuspocus) websocket server. The browser
opens that socket from the OpenProject page, and OpenProject's Content Security
Policy sets `connect-src 'self'` — it never adds the Hocuspocus host. So the
websocket has to arrive on the *same* origin as the app.

Railway's edge routes by host only; it cannot split one domain across two
services by path. This Caddy service does that split:

| Path | Upstream |
|---|---|
| `/healthz` | answered by Caddy itself |
| `/hocuspocus*` | `hocuspocus.railway.internal:1234` |
| everything else | `openproject-web.railway.internal:8080` |

A side benefit: the Rails app and the websocket server both stay private.

## Variables

| Variable | Default | Purpose |
|---|---|---|
| `PORT` | `8080` | set by Railway |
| `OPENPROJECT_WEB_HOST` | `openproject-web.railway.internal:8080` | Rails web service |
| `HOCUSPOCUS_HOST` | `hocuspocus.railway.internal:1234` | collaborative editing server |

Both host variables are optional. `entrypoint.sh` repairs them **on their
shape** before Caddy starts: a value that is empty or begins with `:` (what a
`${{service.RAILWAY_PRIVATE_DOMAIN}}` reference renders as before that service
owns its first deployment — which is every service in a fresh template deploy)
falls back to the deterministic private hostname. Caddy's own `{$VAR:default}`
cannot do this, because it only fires when the variable is *unset*.

## Health check

`/healthz`. It deliberately does not probe an upstream: a private hostname does
not resolve until that service owns a container, so a proxy that health-checks
what it proxies fails its own first deployment.

## Licence

The Caddyfile and Dockerfile here are trivial glue and are published under the
MIT licence. OpenProject itself is GPL-3.0.
