FROM debian:11-slim

EXPOSE 443

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
	&& rm -fr download.html \
	&& curl -SL "gitlab.com/openconnect/ocserv/-/archive/$OC_VERSION/$OC_FILE.tar.gz" -o ocserv.tar.gz \
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
RUN set -x \
	&& sysctl -w net.ipv4.ip_forward=1 \
	&& iptables -t nat -A POSTROUTING -j MASQUERADE \
	&& iptables -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu \
	&& mkdir -p /dev/net \
	&& mknod /dev/net/tun c 10 200 \
	&& chmod 600 /dev/net/tun

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["ocserv", "-c", "/etc/ocserv/ocserv.conf", "-f"] 
