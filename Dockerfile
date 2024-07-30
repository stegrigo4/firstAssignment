# Base stage
FROM alpine as base

RUN apk update && \
    apk upgrade && \
    apk add nginx php83 php83-fpm php83-mysqli curl

RUN mkdir /nginx_php

COPY nginx.conf /etc/nginx/nginx.conf
COPY www.conf /etc/php83/php-fpm.d/www.conf
COPY php.ini /etc/php83/php.ini
COPY index.php /nginx_php/

# WORKDIR $WORKDIRECTORY

# COPY start.sh test.php $WORKDIRECTORY/
# RUN chmod +x start.sh test.phpxx
# RUN echo "<html><body><h1>Hello, </h1></body></html>" > $WORKDIRECTORY/index.html
COPY start.sh start.sh

RUN chmod u+x start.sh

# Test stage
FROM base as test
HEALTHCHECK CMD curl --fail http://localhost:80 || exit 1
CMD ./start.sh

# Prod stage
FROM base as prod
HEALTHCHECK CMD curl --fail http://localhost:80 || exit 1
CMD ./start.sh