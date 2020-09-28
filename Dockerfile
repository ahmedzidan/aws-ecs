FROM nginx:alpine

RUN adduser -u 1000 -D -S -G www-data www-data

RUN mkdir -p /var/tmp/log/ && \
    chown -R www-data:www-data /var/tmp/log/

ADD ./app /usr/share/nginx/html
ADD ./app /var/www/html

ADD ./environment/nginx/config/. /etc/nginx/
