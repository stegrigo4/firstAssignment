FROM alpine as base

RUN apk update && \
    apk upgrade && \
    apk add nginx php83 php83-fpm php83-mysqli curl

RUN mkdir /nginx_php

COPY nginx.conf /etc/nginx/nginx.conf
COPY index.php /nginx_php/
COPY start.sh start.sh

RUN chmod u+x start.sh
RUN rm /etc/nginx/http.d/*.conf

FROM base as test
RUN apk add strace bind-tools
HEALTHCHECK CMD curl --fail http://localhost:80 || exit 1
CMD ./start.sh

FROM base as prod
HEALTHCHECK CMD curl --fail http://localhost:80 || exit 1
CMD ./start.sh