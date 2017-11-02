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
        python \
	"\
	set -x \
	&& apt-get update && apt-get install -y $buildDeps --no-install-recommends \
	&& docker-php-ext-install -j$(nproc) bz2 zip exif bcmath sysvsem pcntl sockets pdo_mysql mysqli intl readline soap xsl xmlrpc

RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

WORKDIR /tmp

RUN curl -fsSL https://github.com/edenhill/librdkafka/archive/v0.11.1.tar.gz -o librdkafka.tar.gz \ 
    && mkdir -p librdkafka \
    && tar -zxf librdkafka.tar.gz -C librdkafka --strip-components=1 \
    && rm librdkafka.tar.gz \
    && ( \
         cd librdkafka \
         && ./configure \
         && make -j$(nproc) \
         && make install \
     ) \
    && rm -r php-ast

RUN curl -fsSL 'https://github.com/nikic/php-ast/archive/v0.1.6.tar.gz' -o php-ast.tar.gz \
	&& mkdir -p php-ast \
	&& tar -xzf php-ast.tar.gz -C php-ast --strip-components=1 \
	&& rm php-ast.tar.gz \
	&& ( \
        cd php-ast \
        && phpize \
        && ./configure \
        && make -j$(nproc) \
        && make install \
    ) \
    && rm -r php-ast \
    && docker-php-ext-enable ast

RUN	pecl install redis \
	pecl install rdkafka \
    pecl install swoole
	
RUN echo "extension=redis.so" > /usr/local/etc/php/conf.d/redis.ini
RUN echo "date.timezone = \"Asia/Shanghai\"" > /usr/local/etc/php/conf.d/timezone.ini

# php config folder
COPY conf.d/* /usr/local/etc/php/conf.d/

RUN rm -r /var/lib/apt/lists/* \
    && rm -r /tmp/*
