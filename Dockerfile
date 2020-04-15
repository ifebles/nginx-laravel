FROM ifebles/nginx-php

RUN apk add php7-bcmath php7-ctype\
  php7-json php7-mbstring php7-pdo \
  php7-xml php7-phar php7-zip php7-dom \
  php7-session php7-pdo_mysql

RUN mkdir /usr/share/nginx/html/public \
  && mv /usr/share/nginx/html/index.php /usr/share/nginx/html/public/

# Set permissions on /usr/share/nginx/html to www-data
RUN chown -R www-data /usr/share/nginx/html/*

# Install and setup composer
RUN ln -s /usr/bin/php7 /usr/local/bin/php \
  && curl https://getcomposer.org/installer -o composer-setup.php \
  && php7 composer-setup.php && rm composer-setup.php \
  && mv composer.phar /usr/local/bin/composer

# Install laravel
RUN composer global require laravel/installer

# Add composer bin directory to PATH
ENV PATH="$PATH:/root/.composer/vendor/bin"

# Change the served root directory
RUN sed "s/\/usr\/share\/nginx\/html;/\/usr\/share\/nginx\/html\/public;/" /etc/nginx/custom-conf/php.conf > /etc/nginx/custom-conf/php.temp.conf \
  && sed "s/\/usr\/share\/nginx\/html;/\/usr\/share\/nginx\/html\/public;/" /etc/nginx/custom-conf/phpfastcgi.conf  > /etc/nginx/custom-conf/phpfastcgi.temp.conf \
  && mv /etc/nginx/custom-conf/php.temp.conf /etc/nginx/custom-conf/php.conf \
  && mv /etc/nginx/custom-conf/phpfastcgi.temp.conf /etc/nginx/custom-conf/phpfastcgi.conf

EXPOSE 80
WORKDIR /usr/share/nginx/html

CMD php-fpm7 && nginx-debug -g "daemon off;"
