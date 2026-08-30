FROM caddy:2-alpine

COPY Caddyfile /etc/caddy/Caddyfile
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# Fail the build, not the boot, on a malformed Caddyfile or entrypoint. Every
# {$VAR} in the Caddyfile carries a default so the adapter has a valid address
# at build time, when nothing is set.
RUN chmod +x /usr/local/bin/entrypoint.sh \
 && sh -n /usr/local/bin/entrypoint.sh \
 && caddy validate --config /etc/caddy/Caddyfile --adapter caddyfile

CMD ["/usr/local/bin/entrypoint.sh"]
