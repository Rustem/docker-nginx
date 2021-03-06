FROM quay.io/sameersbn/ubuntu:14.04.20151023
MAINTAINER sameer@damagehead.com

ENV RTMP_VERSION=1.1.7 \
    NPS_VERSION=1.9.32.4 \
    NGINX_VERSION=1.9.4 \
    NGINX_USER=www-data \
    NGINX_SITECONF_DIR=/etc/nginx/sites-enabled \
    NGINX_LOG_DIR=/var/log/nginx \
    NGINX_TEMP_DIR=/var/lib/nginx \
    NGINX_SETUP_DIR=/var/cache/nginx

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y perl libssl1.0.0 libxslt1.1 libgd3 libxpm4 libgeoip1 libav-tools \
 && rm -rf /var/lib/apt/lists/*

COPY setup/ ${NGINX_SETUP_DIR}/
RUN bash ${NGINX_SETUP_DIR}/install.sh

COPY nginx.conf /etc/nginx/nginx.conf
COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80/tcp 443/tcp 1935/tcp
VOLUME ["${NGINX_SITECONF_DIR}"]
ENTRYPOINT ["/sbin/entrypoint.sh"]
CMD ["/usr/sbin/nginx"]
