# nginx.conf.tpl – rendered by Terraform templatefile()
# Values injected: domain, host, port, exposed_port


# Local access (plain HTTP, no TLS required on loopback)
server {
    listen ${exposed_port};
    server_name localhost 127.0.0.1;

    client_max_body_size 0;

    location / {
        proxy_pass         http://${host}:${port};
        proxy_http_version 1.1;

        proxy_set_header   Host              $host;
        proxy_set_header   X-Real-IP         $remote_addr;
        proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header   Upgrade    $http_upgrade;
        proxy_set_header   Connection "upgrade";

        proxy_read_timeout 3600s;
    }
}


# Redirect bare HTTP → HTTPS
server {
    listen 80;
    server_name ${domain};

    # Allow Cloudflare Tunnel health checks on HTTP
    location /.cloudflare/ {
        return 200 "ok";
        add_header Content-Type text/plain;
    }

    location / {
        return 301 https://$host$request_uri;
    }
}

server {
    listen 443 ssl;
    server_name ${domain};

    # ── TLS ──────────────────────────────────────────────────────────────────
    # For local dev use self-signed certs; for production point at your real certs
    # or rely on Cloudflare for TLS termination (set to flexible/full in CF dashboard).
    ssl_certificate     /etc/nginx/certs/fullchain.pem;
    ssl_certificate_key /etc/nginx/certs/privkey.pem;

    ssl_protocols       TLSv1.2 TLSv1.3;
    ssl_ciphers         HIGH:!aNULL:!MD5;
    ssl_session_cache   shared:SSL:10m;
    ssl_session_timeout 1d;

    # ── Security headers ──────────────────────────────────────────────────────
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options SAMEORIGIN always;
    add_header X-Content-Type-Options nosniff always;

    # ── Proxy to copyparty ────────────────────────────────────────────────────
    client_max_body_size 0;           # copyparty handles large uploads

    location / {
        proxy_pass         http://${host}:${port};
        proxy_http_version 1.1;

        proxy_set_header   Host              $host;
        proxy_set_header   X-Real-IP         $remote_addr;
        proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;

        # WebSocket support (copyparty uses it for live updates)
        proxy_set_header   Upgrade    $http_upgrade;
        proxy_set_header   Connection "upgrade";

        proxy_read_timeout 3600s;
        proxy_send_timeout 3600s;
    }
}

