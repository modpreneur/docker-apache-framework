FROM php:7.1-rc-apache


MAINTAINER Martin Kolek <kolek@modpreneur.com>

# install packages, apcu, bcmath for rabbit, composer with plugin for paraller install, clean apache sites
RUN apt-get update && apt-get -y install \
    apt-utils \
    curl \
    git \
    libcurl4-openssl-dev \
    libpq-dev \
    libpq5 \
    zlib1g-dev \
    libbz2-dev \
    wget\
    libmcrypt-dev \
    openssh-server \
    openssh-client \

    && docker-php-ext-install curl json mbstring opcache zip bz2 mcrypt pdo_mysql pdo_pgsql\

    && pecl install -o -f apcu-5.1.7 apcu_bc-beta \
    && rm -rf /tmp/pear \
    && echo "extension=apcu.so" > /usr/local/etc/php/conf.d/apcu.ini \
    && echo "extension=apc.so" >> /usr/local/etc/php/conf.d/apcu.ini \

    && docker-php-ext-configure bcmath \
    && docker-php-ext-install bcmath \

    && curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/bin/composer \

    && rm -rf /etc/apache2/sites-available/* /etc/apache2/sites-enabled/* \

    && touch /usr/local/etc/php/php.ini \
    && echo "memory_limit = 2048M" >> /usr/local/etc/php/php.ini \

    && mkdir /var/app \
    && mkdir /var/app/web


#set apache site, enable rewrite
COPY docker/000-default.conf /etc/apache2/sites-available/000-default.conf

ENV APP_DOCUMENT_ROOT /var/app/web \
 && APACHE_RUN_USER www-data \
 && APACHE_RUN_GROUP www-data \
 && APACHE_LOG_DIR /var/log/apache2

# enable apache and mod rewrite
RUN a2ensite 000-default.conf \
    && a2enmod expires \
    && a2enmod rewrite \
    && service apache2 restart


WORKDIR /var/app

RUN echo "modpreneur/apache-framework:1.0.2" >> /home/versions