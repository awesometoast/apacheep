FROM ubuntu:latest

# This will bypass prompts that require user input while installing things.
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
ENV APACHE_RUN_USER=www-data
ENV APACHE_RUN_USER=staff

# Recommend using "apt-get" instead of "apt"
RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install -y apt-utils

# Apache2 and associated modules
RUN apt-get install -y apache2
RUN apt-get install -y libapache2-mod-php

# PHP and extensions
RUN apt-get install -y php
RUN apt-get install -y php-bz2
RUN apt-get install -y php-common
RUN apt-get install -y php-curl
RUN apt-get install -y php-dev
RUN apt-get install -y php-gd
RUN apt-get install -y php-mbstring
RUN apt-get install -y php-pdo
RUN apt-get install -y php-pdo-mysql
RUN apt-get install -y php-zip

# OTHER STUFF
# RUN apt-get install -y software-properties-common
RUN apt-get install -y nano
RUN apt-get install -y git
RUN apt-get install -y composer
RUN apt-get install -y tree
RUN apt-get install -y rename
  # Here are a few other popular items:
  # RUN apt-get install -yq nodejs npm pwgen wget vim

# Apply your custom configuration files
COPY ./configs/apache2.conf /etc/apache2/apache2.conf
COPY ./configs/php.ini      /etc/php/7.4/apache2/php.ini

# Copy your application files and set up the volume
ADD html/ /var/www/html
VOLUME "/html"

RUN chown -R www-data:staff /var/www/html
RUN rm /var/www/html/index.html

# Copy and run the additional configuration script
# By default, this creates an alias for httpd="apache2" (just as an example)
COPY ./configs/init_script.sh /usr/sbin/
RUN chmod +x /usr/sbin/init_script.sh
RUN /usr/sbin/init_script.sh

# Tidy up unused dependencies
RUN apt-get autoremove -y

# Launch Apache and run it in the foreground
# Being in the "foreground" means Apache is the primary service at play. It should always run, and if it stops or restarts, the whole container will do the same.
CMD ["apache2ctl", "-D", "FOREGROUND"]
RUN a2enmod rewrite
RUN service apache2 restart

# Expose ports
EXPOSE 80
EXPOSE 443