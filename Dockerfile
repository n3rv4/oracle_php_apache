FROM php:7.4-apache

COPY ./_oracle/instantclient_19_6 /usr/local/instantclient_19_6

RUN apt-get update && apt-get -y install libzip-dev \
  && ln -s /usr/local/instantclient_19_6 /usr/local/instantclient \
  && ln -s /usr/local/instantclient/lib* /usr/lib \
  && ln -s /usr/local/instantclient/sqlplus /usr/bin/sqlplus \
  && chmod 755 -R /usr/local/instantclient \
  && docker-php-ext-configure oci8 --with-oci8=instantclient,/usr/local/instantclient \
  && docker-php-ext-install oci8 \
  && docker-php-ext-install pdo_mysql exif opcache \
  && apt-get install -y libicu-dev libaio-dev libxml2-dev libjpeg-dev libpng-dev libfreetype6-dev libldap2-dev\
  && docker-php-ext-install intl soap dom \
  && docker-php-ext-configure gd --with-freetype --with-jpeg \
  && docker-php-ext-install gd \
  && docker-php-ext-install zip \
  && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
  && docker-php-ext-install ldap \
  && apt-get install -y imagemagick vim wget telnet cron sudo git npm\
  && apt-get purge -y --auto-remove \
  && apt-get clean -y \
  && npm install -g yarn \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir -p /var/www/html/public \
  && a2enmod headers rewrite \
  && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

COPY _conf/charset.conf /etc/apache2/conf-available/charset.conf
COPY _php/timezone.ini /usr/local/etc/php/conf.d/timezone.ini
COPY _php/vars.ini /usr/local/etc/php/conf.d/vars.ini

RUN cp -f "/usr/local/etc/php/php.ini-production" /usr/local/etc/php/php.ini

RUN touch /app/.env
RUN touch /etc/apache2/sites-available/000-default.conf
RUN touch /app/oracle_credentials/tnsnames.ora

WORKDIR /app

ENV TNS_ADMIN="/app/oracle_credentials/"