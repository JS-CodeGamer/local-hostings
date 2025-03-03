FROM nextcloud:fpm-alpine

RUN apk add vim ffmpeg rsync --no-cache

RUN echo '0 0 * * * sh /daily-maintenance.sh' | tee -a /var/spool/cron/crontabs/root
RUN echo '0 0 * * * php /var/www/nextcloud/occ preview:pre-generate' | tee -a /var/spool/cron/crontabs/www-data

COPY ./daily-maintenance.sh /daily-maintenance.sh
