FROM certbot/certbot:latest

RUN apt-get update && \
    apt-get install -y cron
RUN mkdir /var/www/certbot

COPY entrypoint.sh /entrypoint.sh
CMD ["/bin/sh", "entrypoint.sh"]