#!/bin/bash

docker login

SCRIPT_DIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

docker run -d --name quick-demo -v "$SCRIPT_DIR"/..:/var/www/quick-demo:Z php:8.2.10-apache-bookworm

docker exec quick-demo mkdir /tmp/quick-demo/cache
docker exec quick-demo mkdir /tmp/quick-demo/log
docker exec quick-demo chown -R www-data:www-data /tmp
docker exec quick-demo sed -i 's|/var/www/html|/var/www/quick-demo/public|g' /etc/apache2/sites-available/000-default.conf
docker exec quick-demo sed -i '/public/r //var//www//quick-demo//quick-demo-apache.conf' /etc/apache2/sites-available/000-default.conf
docker exec quick-demo sed -i 's|#ServerName www.example.com|ServerName http://localhost|g' /etc/apache2/sites-available/000-default.conf
docker exec quick-demo mv "/usr/local/etc/php/php.ini-development" "/usr/local/etc/php/php.ini"
docker exec quick-demo apt update
docker exec quick-demo apt install -y libicu-dev libmagickwand-dev dnsmasq vim libzip-dev git zip unzip locales locales-all
docker exec quick-demo docker-php-ext-install intl gettext
docker exec quick-demo pear config-set php_ini /usr/local/etc/php/php.ini
docker exec quick-demo pecl install apcu
docker exec quick-demo docker-php-ext-install mysqli pdo_mysql > /dev/null
docker exec quick-demo a2enmod rewrite
docker exec quick-demo pecl install imagick
docker exec quick-demo pecl install zip
docker exec quick-demo bash -c "cd /tmp; curl -O http://www.xmailserver.org/libxdiff-0.23.tar.gz; tar -xzf libxdiff-0.23.tar.gz; cd libxdiff-0.23/; ./configure; make; make install; cd ~"
docker exec quick-demo bash -c "yes '' | pecl install xdiff"
docker exec quick-demo pecl install xdebug
docker exec quick-demo docker-php-ext-enable xdebug
docker exec quick-demo /bin/bash -c "echo -e 'xdebug.idekey = quick-demo\nxdebug.mode = debug\nxdebug.client_host = host.docker.internal\nxdebug.client_port = 9003\nxdebug.start_with_request=yes\nxdebug.log=/var/log/apache2/xdebug.log\nxdebug.discover_client_host=false' >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini"
docker exec quick-demo sed -i 's|;opcache.preload_user=|opcache.preload_user=www-data|g' /usr/local/etc/php/php.ini
docker exec quick-demo sed -i 's|;zend_extension=opcache|zend_extension=opcache|g' /usr/local/etc/php/php.ini
docker exec quick-demo sed -i 's|;opcache.enable=1|opcache.enable=1|g' /usr/local/etc/php/php.ini
docker exec quick-demo sed -i 's|;opcache.validate_timestamps=1|opcache.validate_timestamps=1|g' /usr/local/etc/php/php.ini
docker exec quick-demo sed -i 's|;opcache.revalidate_freq=2|;opcache.revalidate_freq=0|g' /usr/local/etc/php/php.ini
docker exec quick-demo /etc/init.d/apache2 reload
docker exec quick-demo php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
docker exec quick-demo php -r "if (hash_file('sha384', 'composer-setup.php') === 'e21205b207c3ff031906575712edab6f13eb0b361f2085f1f1237b7126d785e826a450292b6cfd1d64d92e6563bbde02') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
docker exec quick-demo php composer-setup.php
docker exec quick-demo php -r "unlink('composer-setup.php');"
docker exec quick-demo mv composer.phar /usr/local/bin/composer

# save container image
docker commit quick-demo | grep sha | sed  -n -e 's/^sha256://p' > /tmp/quick-demo-image-id

if [[ $MACHTYPE = x86_64* ]]
then
    docker tag "$(cat /tmp/quick-demo-image-id)" paullallier/quick-demo:amd
	docker image push paullallier/quick-demo:amd
else
	docker tag "$(cat /tmp/quick-demo-image-id)" paullallier/quick-demo:arm
	docker image push paullallier/quick-demo:arm
fi

docker kill quick-demo
docker container rm --force quick-demo

docker manifest rm paullallier/quick-demo:latest
docker manifest create --amend paullallier/quick-demo:latest \
    paullallier/quick-demo:arm \
    paullallier/quick-demo:amd
docker manifest push paullallier/quick-demo:latest
