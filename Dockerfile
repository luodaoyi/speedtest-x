FROM php:7.4-alpine3.13

WORKDIR /var/www/html/

ENV APACHE_DOCUMENT_ROOT /var/www/html/ 

RUN apk add gnu-libiconv=1.15-r3 --update --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.13/community
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

RUN apk add --no-cache \
        apache2 \
        php-apache2 \
        freetype \
        freetype-dev \
        libpng \
        libpng-dev \
        libjpeg-turbo \
        libjpeg-turbo-dev \
    && docker-php-ext-install -j$(nproc) iconv \
    && docker-php-ext-configure gd --with-freetype --with-jpeg  \
    && docker-php-ext-install -j$(nproc) gd \
    && apk del --no-cache freetype-dev libpng-dev libjpeg-turbo-dev \
    && rm -rf /var/cache/apk/*

# ref  https://stackoverflow.com/questions/55263931/how-to-deploy-a-laravel-web-application-on-alpine-linux-using-docker

RUN chown -R www-data:www-data /var/www/html/  \
    && sed -i '/LoadModule rewrite_module/s/^#//g' /etc/apache2/httpd.conf \
    && sed -i '/LoadModule session_module/s/^#//g' /etc/apache2/httpd.conf \
    && sed -ri -e 's!/var/www/localhost/htdocs!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/httpd.conf \
    && sed -i 's/AllowOverride\ None/AllowOverride\ All/g' /etc/apache2/httpd.conf 

COPY backend/ backend
COPY chartjs/ chartjs
COPY *.js .
COPY *.html .
COPY docker/entrypoint.sh /entrypoint.sh

ENV TIME_ZONE=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TIME_ZONE /etc/localtime && echo $TIME_ZONE > /etc/timezone
RUN printf '[PHP]\ndate.timezone = "Asia/Shanghai"\n' > /usr/local/etc/php/conf.d/tzone.ini

# Prepare environment variabiles defaults

ENV WEBPORT=80
ENV MAX_LOG_COUNT=100
ENV IP_SERVICE="ip.sb"
ENV SAME_IP_MULTI_LOGS="false"

VOLUME ["/speedlogs"]

# Final touches
EXPOSE 80
ENTRYPOINT ["sh", "/entrypoint.sh"]