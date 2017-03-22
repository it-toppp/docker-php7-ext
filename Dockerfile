FROM php:7.1-fpm

MAINTAINER MrGeneral <mrgeneralgoo@gmail.com>

RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak \
    && echo "deb http://mirrors.163.com/debian/ jessie main non-free contrib" >/etc/apt/sources.list \
    && echo "deb http://mirrors.163.com/debian/ jessie-proposed-updates main non-free contrib" >>/etc/apt/sources.list \
    && echo "deb-src http://mirrors.163.com/debian/ jessie main non-free contrib" >>/etc/apt/sources.list \
    && echo "deb-src http://mirrors.163.com/debian/ jessie-proposed-updates main non-free contrib" >>/etc/apt/sources.list

RUN buildDeps=" \
		zlib1g-dev \
	"\
	set -x \
	&& apt-get update && apt-get install -y $buildDeps --no-install-recommends \
	&& docker-php-ext-install -j$(nproc) zip bcmath sysvsem pcntl sockets pdo_mysql mysqli\
	&& pecl install redis \
	&& apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $buildDeps \
	&& rm -r /var/lib/apt/lists/* \
	&& rm -r /tmp/*
