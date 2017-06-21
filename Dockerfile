FROM php:7.1.6-apache
MAINTAINER Nicholas Maietta <nick@icode4u.com>

LABEL Description="BigfootCMS" Vendor="Nicholas Maietta" Version="17.06.21-alpha"

# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE \
	org.label-schema.docker.dockerfile="/Dockerfile" \
	org.label-schema.license="GPLv3" \
	org.label-schema.name="BigfootCMS" \
	org.label-schema.url="https://www.bigfootcms.com/" \
	org.label-schema.vcs-ref=$VCS_REF \
	org.label-schema.vcs-type="Git Source Repository" \
	org.label-schema.vcs-url="https://github.com/bigfootcms/webserver"

RUN apt-get update && apt-get install -y libpng12-dev libjpeg-dev libpq-dev mysql-client vim \
	&& rm -rf /var/lib/apt/lists/* \
	&& docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
	&& docker-php-ext-install gd mbstring pdo mysqli pdo_mysql pdo_pgsql \
	&& /usr/sbin/a2enmod rewrite \
	&& /usr/sbin/a2enmod cgi

# Adding in Health Check Monitor (Add a host config designed to drop access entry logging for these checks, using what's already in hosts file not already being used by apache)
HEALTHCHECK --interval=3s --timeout=5s --retries=2 CMD curl -A 'Heathcheck Request' -f http://healthcheck:81/ || exit 1
COPY configs/healthchecking/healthcheck.conf /etc/apache2/sites-enabled/000-healthchecks.conf

RUN mkdir /var/www/healthchecks
RUN sed -i "1s/^/ServerName localhost\n/" /etc/apache2/apache2.conf

RUN mv /etc/apache2/sites-enabled/000-default.conf /etc/apache2/sites-enabled/001-localhost.conf
RUN sed -i -e 's/webmaster@localhost/no-reply@icode4u.com/g' /etc/apache2/sites-enabled/001-localhost.conf
RUN sed -i -e 's/#ServerName www.example.com/ServerName localhost/g' /etc/apache2/sites-enabled/001-localhost.conf
RUN sed -i -e 's/Listen 80/Listen 80\r\nListen 81/g' /etc/apache2/ports.conf
RUN sed -i -e 's/Options Indexes FollowSymLinks/Options Indexes FollowSymLinks ExecCGI\n\tAddHandler cgi-script .pl .cgi/g' /etc/apache2/apache2.conf

COPY configs/php.ini /usr/local/etc/php/
COPY configs/healthchecking/response-for-healthcecks.html /var/www/healthchecks/

COPY core/ /var/www/html/

WORKDIR /var/www/html

RUN chown www-data:www-data -R /var/www/*

EXPOSE 80

#CMD ['service apache2 start']
