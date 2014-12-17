FROM unicell/tutum-lamp-mysql-stripped:latest
MAINTAINER Qiu Yu <unicell@gmail.com>

# Install plugins
RUN apt-get update && \
  apt-get -y install php5-gd && \
  rm -rf /var/lib/apt/lists/*

# Download latest version of Wordpress into /app
RUN rm -fr /app && git clone --depth=1 https://github.com/WordPress/WordPress.git /app

# Configure Wordpress to connect to local DB
ADD wp-config.php /app/wp-config.php

# Modify permissions to allow plugin upload
RUN chown -R www-data:www-data /app/wp-content /var/www/html

# Let's get serf
RUN apt-get update; apt-get install -qqy unzip
ADD https://dl.bintray.com/mitchellh/serf/0.6.3_linux_amd64.zip serf.zip
RUN unzip serf.zip
RUN mv serf /usr/bin/

# supervisor included in base image
ADD /start-apache2.sh /start-apache2.sh
ADD /start-serf.sh /start-serf.sh
ADD /serf-join.sh /serf-join.sh
ADD /supervisord-serf.conf /etc/supervisor/conf.d/supervisord-serf.conf
RUN chmod 755 /*.sh

# Configure Wordpress to connect to local DB
ADD wp-config.php /app/wp-config.php

EXPOSE 80
CMD ["/run.sh"]
