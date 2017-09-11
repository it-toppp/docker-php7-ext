FROM php:7-fpm

MAINTAINER MrGeneral <mrgeneralgoo@gmail.com>

RUN buildDeps=" \
	    libbz2-dev \
	    libedit-dev \
	    libfreetype6-dev \
	    libicu-dev \
	    libjpeg62-turbo-dev \
	    libkrb5-dev \
	    libpng12-dev \
	    libpq-dev \
	    libxml2-dev \
		zlib1g-dev \
    	libxslt1-dev \
	"\
	set -x \
	&& apt-get update && apt-get install -y $buildDeps --no-install-recommends \
	&& docker-php-ext-install -j$(nproc) bz2 zip exif bcmath sysvsem pcntl sockets pdo_mysql mysqli intl readline soap xsl xmlrpc

RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

RUN	pecl install redis \
RUN	pecl install rdkafka \
	&& rm -r /var/lib/apt/lists/* \
	&& rm -r /tmp/*



RUN echo "extension=redis.so" > /usr/local/etc/php/conf.d/redis.ini
RUN echo "date.timezone = \"Asia/Shanghai\"" >> /usr/local/etc/php/conf.d/timezone.ini
