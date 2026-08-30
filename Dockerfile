FROM caddy:2-alpine

COPY Caddyfile /etc/caddy/Caddyfile

# Fail the build, not the boot, on a malformed Caddyfile. Every {$VAR} above
# carries a default so the adapter has a valid address at build time.
RUN caddy validate --config /etc/caddy/Caddyfile --adapter caddyfile

CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
