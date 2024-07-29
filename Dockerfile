FROM alpine as test

RUN apk update && \
    apk upgrade && \
    apk add kfind nginx php83 php83-fpm

ENV WORKDIRECTORY /usr/share/nginx/html

COPY nginx.conf /etc/nginx/nginx.conf

COPY www.conf /etc/php83/php-fpm.d/www.conf

COPY php.ini /etc/php83/php.ini

WORKDIR $WORKDIRECTORY

COPY start.sh test.php $WORKDIRECTORY/

RUN chmod +x start.sh test.php

RUN echo "<html><body><h1>Hello, Docker Nginx!</h1></body></html>" > $WORKDIRECTORY/index.html

CMD ./start.sh

FROM alpine as prod

RUN apk update && \
    apk upgrade && \
    apk add kfind nginx php83 php83-fpm

ENV WORKDIRECTORY /usr/share/nginx/html

COPY nginx.conf /etc/nginx/nginx.conf

COPY www.conf /etc/php83/php-fpm.d/www.conf

COPY php.ini /etc/php83/php.ini

WORKDIR $WORKDIRECTORY

COPY start.sh test.php $WORKDIRECTORY/

RUN chmod +x start.sh test.php

RUN echo "<html><body><h1>Hello, Docker Nginx!</h1></body></html>" > $WORKDIRECTORY/index.html

CMD ./start.sh