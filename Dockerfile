FROM composer:latest
FROM ubuntu:latest

# -------------------------------------------------------
# GETTING READY
# -------------------------------------------------------

# Environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
ENV APACHE_RUN_USER=www-data
ENV APACHE_RUN_USER=staff
ENV APP_DIR=/app

# Prep for installing Apache/PHP/etc
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y apt-utils


# -------------------------------------------------------
# INSTALL APACHE 2.4
# -------------------------------------------------------

# Initial install, plus the FastCGI module we'll use with PHP
RUN apt-get install -y apache2 libapache2-mod-fcgid

# Copy our custome Apache configs
COPY ./configs/apache2.conf /etc/apache2/apache2.conf

# Disable the default Apache site and replace it with our own
RUN a2dissite 000-default
COPY ./configs/app.conf /etc/apache2/sites-available/app.conf
RUN a2ensite app

# Enable Apache modules
# Add or remove as desired. Check here for a full list:
# https://httpd.apache.org/docs/current/mod/
RUN a2enmod rewrite headers http2 ssl


# -------------------------------------------------------
# PHP + FASTCGI
#
# FastCGI is faster than the standard mod_php and allows us to use HTTP/2
# -------------------------------------------------------

# Install PHP and extensions
# Add or remove as desired. Check here for a full list:
# https://www.php.net/manual/en/extensions.php
RUN apt-get install -y php
RUN apt-get install -y php-bcmath
RUN apt-get install -y php-bz2
RUN apt-get install -y php-common
RUN apt-get install -y php-cgi
RUN apt-get install -y php-curl
RUN apt-get install -y php-dev
RUN apt-get install -y php-fileinfo
RUN apt-get install -y php-mbstring
RUN apt-get install -y php-pdo
RUN apt-get install -y php-pdo-mysql
RUN apt-get install -y php-zip

# To use FastCGI, we have to disable Apache's classic PHP module first
# (mod_php/php8.1)
# We also need to swap mpm_prefork for mpm_worker
# Trivia: MPM stands for Multi-Processing Module
RUN a2dismod php8.1 mpm_prefork
RUN a2enmod fcgid mpm_worker

# FastCGI involves a "wrapper script"
COPY ./configs/php-fcgid-wrapper.sh /usr/local/bin/php-fcgid-wrapper
RUN chmod +x /usr/local/bin/php-fcgid-wrapper

# Among other things, this custom .conf tells Apache to use the
# wrapper script above and where to find it
COPY ./configs/php-cgi.conf /etc/apache2/conf-available/php-cgi.conf
RUN a2enconf php-cgi

# And finally, our general PHP configs
COPY ./configs/php.ini      /etc/php/8.1/cgi/php.ini


# -------------------------------------------------------
# OTHER STUFF
# Like git & Composer
# -------------------------------------------------------
RUN apt-get install -y git
RUN apt-get install -y nano

# COMPOSER
# We can grab this from their official Docker image like so:
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# NPM
# It's hefty, so it's not installed by default.
# Uncomment the next line to install it:
# RUN apt-get install -y npm


# -------------------------------------------------------
# FINISHING UP
# -------------------------------------------------------

# Tidy up unused dependencies
RUN apt-get autoremove -y

# Copy our site's files and set up the volume
RUN mkdir /app
RUN chown -R www-data:staff /app
ADD app/ /app
VOLUME "/app"
WORKDIR /app

# Launch Apache and run it in the foreground
# Trivia: Being in the "foreground" means Apache is the primary service at play. It should always run, and if it stops or restarts, the whole container will do the same
CMD ["apache2ctl", "-D", "FOREGROUND"]
RUN service apache2 restart

# Expose ports
EXPOSE 80
EXPOSE 443
