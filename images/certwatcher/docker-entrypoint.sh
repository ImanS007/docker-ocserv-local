#!/bin/sh
certbot certonly --webroot -w /var/www/certbot -d test.leangaurav.com --text --agree-tos --email your.email@email.com --rsa-key-size 4096 --verbose --keep-until-expiring --preferred-challenges=http

# Start the cron service
service cron start 

# Add new cron job
echo "0 */12 * * * root certbot renew --quiet --no-self-upgrade --post-hook 'cp /etc/letsencrypt/live/your_domain/* /etc/certs/ && service nginx reload' >> /var/log/cron.log 2>&1" > /etc/cron.d/renew
