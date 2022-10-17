FROM php:7.4-alpine

WORKDIR /var/www/html/

ENV APACHE_DOCUMENT_ROOT /var/www/html/

RUN apk add --no-cache apache2 php-apache2 
RUN apk add --no-cache freetype libpng libjpeg-turbo freetype-dev libpng-dev libjpeg-turbo-dev && \
  docker-php-ext-install -j$(nproc) iconv \
  docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg \
  NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) && \
  docker-php-ext-install -j$(nproc) gd && \
  apk del --no-cache freetype-dev libpng-dev libjpeg-turbo-dev

 
# Prepare files and folders

RUN mkdir -p /var/www/html/

# Copy sources

COPY backend/ ./backend
COPY chartjs/ ./chartjs

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