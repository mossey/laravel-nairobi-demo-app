FROM php:7.2-apache

# Install all the system dependencies and enable PHP modules
RUN apt-get update && apt-get install -y \
  zlib1g-dev \
  libicu-dev \
  libpq-dev \
  git \
  zip \
  unzip \
  openssl \
  ufw \
  logrotate \
  && rm -r /var/lib/apt/lists/* \
  && docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd \
  && docker-php-ext-install \
  intl \
  mbstring \
  pcntl \
  pdo_mysql \
  pdo_pgsql \
  pgsql \
  zip \
  opcache \
  bcmath 


RUN  echo "ServerTokens Prod" >> /etc/apache2/apache2.conf
RUN  echo "ServerSignature Off " >> /etc/apache2/apache2.conf
#RUN  systemctl restart apache2


# Install composer

RUN curl -sS  -k --insecure https://getcomposer.org/installer | php && chmod +x composer.phar && mv composer.phar /usr/local/bin/composer

# Set our application folder as an environment variable
ENV APP_HOME /var/www/html

# Change uid and gid of apache to docker user uid/gid
RUN usermod -u 1000 www-data && groupmod -g 1000 www-data

# Configuration for Apache
RUN rm -rf /etc/apache2/sites-enabled/000-default.conf
ADD docker_config/apache/server.conf /etc/apache2/sites-available/
RUN ln -s /etc/apache2/sites-available/server.conf /etc/apache2/sites-enabled/



# Enable apache module rewrite
RUN a2enmod rewrite
RUN a2enmod ssl

# Copy source files and run composer
COPY . $APP_HOME

# Change working directory
WORKDIR $APP_HOME

# Install all PHP dependencies
RUN composer install --no-interaction

# Change ownership of our applications
RUN chown -R www-data:www-data $APP_HOME

RUN touch storage/logs/laravel.log

EXPOSE 443
EXPOSE 80

ARG RUNSCRIPT=$APP_HOME"/run.sh"
ADD docker_config/run.sh $RUNSCRIPT
RUN chmod +x $RUNSCRIPT
CMD ["/var/www/html/run.sh"] 