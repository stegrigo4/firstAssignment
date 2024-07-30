# Base stage
FROM alpine as base

RUN apk update && \
    apk upgrade && \
    apk add nginx php83 php83-fpm curl

ENV WORKDIRECTORY /usr/share/nginx/html

COPY nginx.conf /etc/nginx/nginx.conf
COPY www.conf /etc/php83/php-fpm.d/www.conf
COPY php.ini /etc/php83/php.ini

WORKDIR $WORKDIRECTORY

COPY start.sh test.php $WORKDIRECTORY/
RUN chmod +x start.sh test.php
RUN echo "<html><body><h1>Hello, Docker Nginx!</h1></body></html>" > $WORKDIRECTORY/index.html

# Test stage
FROM base as test
HEALTHCHECK CMD curl --fail http://localhost:9090 || exit 1
CMD ./start.sh

# Prod stage
FROM base as prod
HEALTHCHECK CMD curl --fail http://localhost:9091 || exit 1
CMD ./start.sh