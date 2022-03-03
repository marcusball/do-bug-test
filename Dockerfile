FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive
ENV NGINX_VERSION 1.20.2
ENV php_conf /etc/php/8.0/fpm/php.ini
ENV fpm_conf /etc/php/8.0/fpm/pool.d/www.conf
ENV COMPOSER_VERSION 2.0.13

# Install Basic Requirements
RUN buildDeps='curl gcc make autoconf libc-dev zlib1g-dev pkg-config' \
    && set -x \
    && apt-get update \
    && apt-get install --no-install-recommends $buildDeps --no-install-suggests -q -y \
    gnupg2 \
    dirmngr \
    wget \
    apt-transport-https \
    lsb-release \
    ca-certificates \
    python \
    strace \ 
    gdb \
    less \
    lsof \
    net-tools \
    build-essential \
    libpcre3 \
    libpcre3-dev \
    zlib1g \
    zlib1g-dev \
    libssl-dev \
    libgd-dev \
    libxml2 \
    libxml2-dev \
    uuid-dev \
    && apt-key adv --batch --keyserver keyserver.ubuntu.com --keyserver-options timeout=10 --recv-keys "14AA40EC0831756756D7F66C4F4EA0AAE5267A6C" \
    && echo "deb https://ppa.launchpadcontent.net/ondrej/php/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list \
    && apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -q -y \
    apt-utils \
    nvi \
    nano \
    zip \
    unzip \
    git \
    libmemcached-dev \
    libmemcached11 \
    libmagickwand-dev \
    php8.0-fpm \
    php8.0-cli \
    php8.0-bcmath \
    php8.0-dev \
    php8.0-common \
    php8.0-opcache \
    php8.0-readline \
    php8.0-mbstring \
    php8.0-curl \
    php8.0-gd \
    php8.0-imagick \
    php8.0-mysql \
    php8.0-zip \
    php8.0-pgsql \
    php8.0-intl \
    php8.0-xml \
    php-pear \
    && pecl -d php_suffix=8.0 install -o -f redis memcached \
    && mkdir -p /run/php \
    && ln -s /usr/sbin/php-fpm8.0 /usr/sbin/php-fpm \
    && echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d \
    # Install Composer
    && curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
    && curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig \
    && php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }" \
    && php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer --version=${COMPOSER_VERSION} \
    && rm -rf /tmp/composer-setup.php \
    # Clean up
    && rm -rf /tmp/pear \
    #    && apt-get purge -y --auto-remove $buildDeps \
    && apt-get clean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

RUN addgroup --system apps
RUN useradd -rm -d /home/apps -s /bin/bash -g apps -u 1001 apps
RUN mkdir -p /workspace/.nginx && mkdir -p /workspace/.nginx/var/run/nginx && ln -s /app /workspace 

WORKDIR /workspace/.nginx/
RUN wget https://nginx.org/download/nginx-1.20.2.tar.gz && tar -xzf nginx-1.20.2.tar.gz
WORKDIR /workspace/.nginx/nginx-1.20.2

RUN sed -i '58c\\if ((ngx_event_flags & NGX_USE_EPOLL_EVENT) && ngx_use_epoll_rdhup) {\\' src/os/unix/ngx_readv_chain.c && \
    sed -i '55c\\if ((ngx_event_flags & NGX_USE_EPOLL_EVENT) && ngx_use_epoll_rdhup) {\\' src/os/unix/ngx_recv.c

RUN ./configure \
    --prefix=/workspace/.nginx \
    --http-fastcgi-temp-path=/workspace/.nginx/var/run/nginx/fastcgi_temp \ 
    --http-uwsgi-temp-path=/workspace/.nginx/var/run/nginx/uwsgi_temp \ 
    --http-scgi-temp-path=/workspace/.nginx/var/run/nginx/scgi_temp \ 
    --http-log-path=/workspace/.nginx/var/log/nginx/access.log \ 
    --error-log-path=/workspace/.nginx/var/log/nginx/error.log \ 
    --with-http_realip_module \ 
    --with-http_ssl_module \
    --with-debug \
    --with-cc-opt='-O0 -g'
RUN make
RUN make install

WORKDIR /workspace

COPY . /workspace

RUN chown -R apps:apps /workspace/

USER apps

CMD ["/workspace/script/heroku-php-nginx", "public/"]
