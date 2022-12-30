FROM hyperf/hyperf:7.4-alpine-v3.12-swoole

ARG timezone

ENV TIMEZONE=${timezone:-"Asia/Shanghai"} \
	APP_DEBUG=true

RUN set -ex \
	&& apk update \
	# install composer
	&& cd /tmp \
	&& wget https://mirrors.aliyun.com/composer/composer.phar \
	&& chmod u+x composer.phar \
	&& mv composer.phar /usr/local/bin/composer \
	# show php version and extensions
	&& php -v \
	&& php -m \
	&& php --ri swoole \
	#  ---------- some config ----------
	&& cd /etc/php7 \
	# - config PHP
	&& { \
	echo "upload_max_filesize=100M"; \
	echo "post_max_size=108M"; \
	echo "memory_limit=1024M"; \
	echo "date.timezone=${TIMEZONE}"; \
	} | tee conf.d/99_overrides.ini \
	# - config timezone
	&& ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
	&& echo "${TIMEZONE}" > /etc/timezone \
	# ---------- clear works ----------
	&& rm -rf /var/cache/apk/* /tmp/* /usr/share/man \
	&& echo -e "\033[42;37m Build Completed :).\033[0m\n"

WORKDIR /app
COPY . /app

EXPOSE 9501

RUN composer install --no-dev -o

ENTRYPOINT ["php", "/app/bin/swoole.php", "start"]