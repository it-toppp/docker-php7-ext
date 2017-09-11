FROM php:fpm

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

# get librdkafka version from https://github.com/edenhill/librdkafka
ENV LIBRDKAFKA_VERSION=0.11.0
RUN curl -fsSL https://github.com/edenhill/librdkafka/archive/v${LIBRDKAFKA_VERSION}.tar.gz -o v${LIBRDKAFKA_VERSION}.tar.gz && \
    tar -zxf v${LIBRDKAFKA_VERSION}.tar.gz && \
    cd librdkafka-${LIBRDKAFKA_VERSION} && \
    ./configure && make && make install

RUN	pecl install redis \
	pecl install rdkafka \
	&& rm -r /var/lib/apt/lists/* \
	&& rm -r /tmp/*
	
RUN echo "extension=redis.so" > /usr/local/etc/php/conf.d/redis.ini
RUN echo "date.timezone = \"Asia/Shanghai\"" >> /usr/local/etc/php/conf.d/timezone.ini
