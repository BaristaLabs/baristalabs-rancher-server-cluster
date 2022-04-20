#!/usr/bin/env pwsh
certbot --manual --preferred-challenges dns certonly -d "*.rancher.baristalabs.io" -d "rancher.baristalabs.io" --config-dir ~/letsencrypt --work-dir ~/letsencrypt --logs-dir ~/letsencrypt
openssl pkcs12 -export `
    -inkey "$HOME/letsencrypt/live/rancher.baristalabs.io/privkey.pem" `
    -in "$HOME/letsencrypt/live/rancher.baristalabs.io/fullchain.pem" `
    -out "$HOME/letsencrypt/live/rancher.baristalabs.io/cert.pfx"