FROM php:7-apache


MAINTAINER Martin Kolek <kolek@modpreneur.com>

# install packages, apcu, bcmath for rabbit, postfix, composer with plugin for paraller install, clean apache sites
RUN apt-get update && apt-get -y install \
    apt-utils \
    curl \
    git \
    libcurl4-openssl-dev \
    libpq-dev \
    libpq5 \
    zlib1g-dev \
    wget\
    libmcrypt-dev \
    openssh-server \
    openssh-client \

    && docker-php-ext-install curl json mbstring opcache zip mcrypt pdo_mysql pdo_pgsql\

    && pecl install -o -f apcu-5.1.5 \
    && rm -rf /tmp/pear \
    && echo "extension=apcu.so" > /usr/local/etc/php/conf.d/apcu.ini \

    && docker-php-ext-configure bcmath \
    && docker-php-ext-install bcmath \

    && curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/bin/composer \
    && composer global require hirak/prestissimo \

    && rm -rf /etc/apache2/sites-available/* /etc/apache2/sites-enabled/*


WORKDIR /var/app
RUN mkdir web

#set apache
ENV APP_DOCUMENT_ROOT /var/app/web \
 && APACHE_RUN_USER www-data \
 && APACHE_RUN_GROUP www-data \
 && APACHE_LOG_DIR /var/log/apache2 \


COPY docker/php.ini /usr/local/etc/php/
COPY docker/000-default.conf /etc/apache2/sites-available/000-default.conf

# enable apache and mod rewrite
RUN a2ensite 000-default.conf \
    && a2enmod expires \
    && a2enmod rewrite \
    && service apache2 restart

RUN echo "modpreneur/apache-framework:0.5" >> /home/versions