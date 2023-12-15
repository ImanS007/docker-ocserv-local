FROM debian:11-slim

# ENV OC_VERSION=1.2.2
RUN buildDeps=" \
		curl \
		gcc \
		gnutls-dev \
		libgpgme11 \
		libev-dev \
		libnl-3-dev \
		libseccomp-dev \
		linux-headers-amd64 \
		libpam0g-dev \
		liblz4-dev \
		make \
		libreadline-dev \
		tar \
		xz-utils \
		autoconf \
		ca-certificates \
		automake \
		pkg-config \
		libcurl4-openssl-dev \
		libcjose0 \
		libcjose-dev \
		libcrypt1 \
		libcrypto++-dev \ 
		libssl-dev \
		protobuf-c-compiler \
		gperf \
		libjansson4 \
		libjansson-dev \
	"; \
	set -x \
	&& ( apt-get update || true ) \
	&& apt-get install -y --no-install-recommends $buildDeps \
	&& curl -SL http://ocserv.gitlab.io/www/download.html -o download.html \
	&& OC_VERSION=`sed -n 's/^.*The latest version of ocserv is \(.*\)$/\1/p' download.html` \
	&& OC_FILE="ocserv-$OC_VERSION" \
	&& rm -fr download.html 

RUN curl -SL "gitlab.com/openconnect/ocserv/-/archive/$OC_VERSION/$OC_FILE.tar.gz" -o ocserv.tar.gz \
	&& mkdir -p /usr/src/ocserv \
	&& tar -xf ocserv.tar.gz -C /usr/src/ocserv --strip-components=1 \
	&& rm ocserv.tar.gz* \
	&& cd /usr/src/ocserv \
	&& autoreconf -fvi \
	&& ./configure --enable-oidc-auth --without-radius \
	&& make \
	&& make install \
	&& mkdir -p /etc/ocserv \
	&& cp /usr/src/ocserv/doc/sample.config /etc/ocserv/ocserv.conf \
	&& cd / \
	&& rm -fr /usr/src/ocserv 

# Setup config
COPY groupinfo.txt /tmp/
RUN set -x \
	&& sed -i 's/\.\/sample\.passwd/\/etc\/ocserv\/ocpasswd/' /etc/ocserv/ocserv.conf \
	&& sed -i 's/\(max-same-clients = \)2/\110/' /etc/ocserv/ocserv.conf \
	&& sed -i 's/\.\.\/tests/\/etc\/ocserv/' /etc/ocserv/ocserv.conf \
	&& sed -i 's/#\(compression.*\)/\1/' /etc/ocserv/ocserv.conf \
	&& sed -i '/^ipv4-network = /{s/192.168.1.0/192.168.99.0/}' /etc/ocserv/ocserv.conf \
	&& sed -i 's/192.168.1.2/8.8.8.8/' /etc/ocserv/ocserv.conf \
	&& sed -i 's/^route/#route/' /etc/ocserv/ocserv.conf \
	&& sed -i 's/^no-route/#no-route/' /etc/ocserv/ocserv.conf \
	&& sed -i '/\[vhost:www.example.com\]/,$d' /etc/ocserv/ocserv.conf \
	&& mkdir -p /etc/ocserv/config-per-group \
	&& cat /tmp/groupinfo.txt >> /etc/ocserv/ocserv.conf \
	&& rm -fr /tmp/cn-no-route.txt \
	&& rm -fr /tmp/groupinfo.txt

WORKDIR /etc/ocserv

COPY All /etc/ocserv/config-per-group/All
COPY cn-no-route.txt /etc/ocserv/config-per-group/Route

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 443
CMD ["ocserv", "-c", "/etc/ocserv/ocserv.conf", "-f"] 
