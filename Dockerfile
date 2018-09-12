FROM php:5.6-apache

RUN a2enmod rewrite expires

# install the PHP extensions we need
RUN apt-get update && apt-get install -y libpng-dev libjpeg-dev libkrb5-dev \
    && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
    && docker-php-ext-install gd mysqli \
    && apt-get -y install libssl-dev libc-client2007e-dev libkrb5-dev \
    && docker-php-ext-configure imap --with-imap-ssl --with-kerberos \
    && docker-php-ext-install imap opcache \
    && apt-get -y install zlib1g-dev bindfs \
    && docker-php-ext-install zip \
    && rm -rf /var/lib/apt/lists/*

# setting the recommended for vtiger
RUN { \
        echo 'display_errors=On'; \
        echo 'max_execution_time=0'; \
        echo 'error_reporting=E_WARNING & ~E_NOTICE & ~E_DEPRECATED & ~E_STRICT'; \
        echo 'log_errors=Off'; \
        echo 'short_open_tag=Off'; \
        echo 'default_charset="utf-8"'; \
    } > /usr/local/etc/php/conf.d/999-vtiger-recommended.ini

# setting the reccomended for opcache
# https://secure.php.net/manual/en/opcache.installation.php
RUN { \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=4000'; \
        echo 'opcache.revalidate_freq=60'; \
        echo 'opcache.fast_shutdown=1'; \
        echo 'opcache.enable_cli=1'; \
    } > /usr/local/etc/php/conf.d/999-opcache-recommended.ini

COPY vtigerweb-entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["apache2-foreground"]