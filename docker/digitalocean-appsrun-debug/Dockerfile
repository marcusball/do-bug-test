FROM digitaloceanapps/apps-run

USER root

RUN apt-get update
RUN apt-get install -y strace gdb lsof net-tools build-essential libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev libgd-dev libxml2 libxml2-dev uuid-dev

WORKDIR /workspace/.nginx
RUN chown apps:apps /workspace/.nginx

# RUN wget https://github.com/PhilipHazel/pcre2/releases/download/pcre2-10.39/pcre2-10.39.tar.gz && \
#     tar-xzf pcre2-10.39.tar.gz && \
#     cd pcre2-10.39.tar.gz && \
#     ./configure && \
#     make install

RUN wget https://nginx.org/download/nginx-1.20.2.tar.gz && tar -xzf nginx-1.20.2.tar.gz
WORKDIR /workspace/.nginx/nginx-1.20.2
# RUN sed -i '502s/.*/        ngx_use_epoll_rdhup = 0;/' src/event/modules/ngx_epoll_module.c
RUN sed -i '875s/.*/#if 1/' src/event/modules/ngx_epoll_module.c

# RUN sed -i '203,216c\\ \
#             if (ngx_event_flags & NGX_USE_EPOLL_EVENT) \
#             { \
#                 if (n < size) { \
#                     if (ngx_use_epoll_rdhup && !rev->pending_eof) { \
#                         rev->ready = 0; \
#                     } \
#  \
#                     rev->available = 0; \
#                 } \
#  \
#                 return n; \
#             } \
# \\' src/os/unix/ngx_readv_chain.c
# 
# RUN sed -i '64i\\ \
#             rev->ready = 0; \
# \\' src/os/unix/ngx_readv_chain.c

RUN sed -i '58c\\if ((ngx_event_flags & NGX_USE_EPOLL_EVENT) && ngx_use_epoll_rdhup) {\\' src/os/unix/ngx_readv_chain.c
RUN sed -i '55c\\if ((ngx_event_flags & NGX_USE_EPOLL_EVENT) && ngx_use_epoll_rdhup) {\\' src/os/unix/ngx_recv.c

RUN ./configure \
    --prefix=/workspace/.nginx \
    --http-fastcgi-temp-path=/workspace/.heroku/php/var/run/nginx/fastcgi_temp \ 
    --http-uwsgi-temp-path=/workspace/.heroku/php/var/run/nginx/uwsgi_temp \ 
    --http-scgi-temp-path=/workspace/.heroku/php/var/run/nginx/scgi_temp \ 
    --http-log-path=/workspace/.heroku/php/var/log/nginx/access.log \ 
    --error-log-path=/workspace/.heroku/php/var/log/nginx/error.log \ 
    --with-http_realip_module \ 
    --with-http_ssl_module \
    --with-debug \
    --with-cc-opt='-O0 -g'
RUN make
RUN make install

USER apps

