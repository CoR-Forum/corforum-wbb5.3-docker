####
## Author:    Joshua Tobias Treudler
## Created:   10.05.2023
## First updated and published: 21.09.2025
##
## (c) Joshua Tobias Treudler
####

FROM mlocati/php-extension-installer:2 AS php_ext_installer

FROM php:7.4-apache

# Use the official PHP extension installer via multi-stage to avoid remote ADD
COPY --from=php_ext_installer /usr/bin/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions && \
    install-php-extensions ctype dom exif json hash libxml \
    mbstring pcre pdo pdo_mysql zlib gd imagick mysqli \
    curl intl zip xml simplexml opcache

### FOR REFERENCE SEE
### https://nelkinda.com/blog/apache-php-in-docker/#d11e196
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Enable required Apache modules and allow .htaccess overrides
RUN set -eux; \
    a2enmod expires headers rewrite; \
    sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf
# COPY php.ini /usr/local/etc/php/
###

COPY cron-00 /etc/cron.d/cron-00

# Harden Apache settings, PHP limits, install packages, configure cron, and cleanup in one layer
RUN set -eux; \
    { echo 'ServerSignature Off'; echo 'ServerTokens Prod'; } >> /etc/apache2/apache2.conf; \
    printf '%s\n' 'upload_max_filesize = 1G;' 'post_max_size = 1G;' 'memory_limit = 512M;' > /usr/local/etc/php/conf.d/uploads.ini; \
    printf '%s\n' \
      'opcache.enable=1;' \
      'opcache.memory_consumption=128;' \
      'opcache.interned_strings_buffer=16;' \
      'opcache.max_accelerated_files=10000;' \
      'opcache.validate_timestamps=0;' \
      'opcache.save_comments=1;' \
      > /usr/local/etc/php/conf.d/opcache.ini; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends cron nano curl; \
    rm -rf /var/lib/apt/lists/*; \
    chmod 0644 /etc/cron.d/cron-00; \
    crontab /etc/cron.d/cron-00; \
    touch /var/log/cron.log; \
    sed -i 's/^exec /service cron start\n\nexec /' /usr/local/bin/apache2-foreground
