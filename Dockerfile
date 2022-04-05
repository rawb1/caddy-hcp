ARG VERSION

FROM caddy:$VERSION-builder-alpine AS builder

RUN xcaddy build --with github.com/pteich/caddy-tlsconsul

FROM caddy:$VERSION-alpine

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

RUN apk add --no-cache tini

COPY signal-handler.sh /

# Override the entrypoint with a bash script which handles SIGHUP and triggers reload
ENTRYPOINT ["/sbin/tini", "--"]

ENV CADDYFILE_PATH /etc/caddy/Caddyfile

ENV ADAPTER caddyfile

CMD ["/signal-handler.sh", "caddy", "run", "--config", "echo ${CADDYFILE_PATH}", "--adapter", "echo ${ADAPTER}"]
