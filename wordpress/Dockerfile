# WordPress (official image) with the Railway fixes done at build time instead of in a start command:
# - only mpm_prefork enabled (mod_php needs it; several Railway WordPress templates fail with
#   "More than one MPM loaded" and patch it on every boot)
# - PHP limits for real sites: 128 MB uploads, 256 MB memory
# - real visitor IPs from Railway's proxy (mod_remoteip), so logs and security plugins see clients
# - WP-CLI (run it from a shell opened with `railway ssh`: wp --allow-root ...)
FROM wordpress:7.1-php8.4-apache

RUN a2dismod -f mpm_event mpm_worker >/dev/null 2>&1 || true \
    && a2enmod mpm_prefork rewrite headers expires remoteip \
    && curl -fsSL -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

COPY php-railway.ini /usr/local/etc/php/conf.d/zz-railway.ini
COPY apache-railway.conf /etc/apache2/conf-available/railway.conf
RUN a2enconf railway
