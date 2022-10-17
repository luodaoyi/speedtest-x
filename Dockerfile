FROM php:7.4-alpine3.13

WORKDIR /var/www/html/

ENV APACHE_DOCUMENT_ROOT /var/www/html/ 

RUN apk add gnu-libiconv=1.15-r3 --update --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.13/community
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php


RUN  apk add --no-cache apache2 php-apache2 freetype freetype-dev libpng libpng-dev libjpeg-turbo libjpeg-turbo-dev 
RUN  docker-php-ext-install -j$(nproc) iconv 
RUN  docker-php-ext-configure gd --with-freetype --with-jpeg 
RUN  docker-php-ext-install -j$(nproc) gd 
RUN  apk del --no-cache freetype-dev libpng-dev libjpeg-turbo-dev

COPY backend/ backend
COPY chartjs/ chartjs
COPY *.js .
COPY *.html .
COPY docker/entrypoint.sh /

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
CMD ["bash", "/entrypoint.sh"]