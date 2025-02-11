FROM caddy:2.7-alpine

COPY Caddyfile /etc/caddy/Caddyfile
COPY index.html /usr/share/caddy/index.html

EXPOSE 8080
