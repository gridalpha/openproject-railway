#!/bin/sh
set -eu

# Railway renders a ${{svc.RAILWAY_PRIVATE_DOMAIN}} reference as an EMPTY string
# until that service owns a deployment. In a template every service deploys for
# the first time at once, so OPENPROJECT_WEB_HOST can arrive as a bare ":8080" —
# which Caddy would happily bake as the upstream "http://:8080" and then 502
# forever, because Caddy's own {$VAR:default} only fires when the variable is
# *unset*, not when it is set to a broken value.
#
# So repair both hosts on their shape, not on their presence.
case "${OPENPROJECT_WEB_HOST-}" in
	"" | :* ) OPENPROJECT_WEB_HOST="openproject-web.railway.internal:8080" ;;
esac
case "${HOCUSPOCUS_HOST-}" in
	"" | :* ) HOCUSPOCUS_HOST="hocuspocus.railway.internal:1234" ;;
esac
export OPENPROJECT_WEB_HOST HOCUSPOCUS_HOST

echo "[proxy] app upstream:        ${OPENPROJECT_WEB_HOST}"
echo "[proxy] hocuspocus upstream: ${HOCUSPOCUS_HOST}"

exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
