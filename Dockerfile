# Original credit: https://github.com/jpetazzo/dockvpn
# Original credit: https://github.com/kylemanna/docker-openvpn
FROM alpine:latest

LABEL maintainer="Mauro Iorio <iorio.mauro@gmail.com>"

# edge/testing: pamtester
RUN set -ue && \
    apk add --no-cache --update --upgrade \
        --repository 'https://dl-cdn.alpinelinux.org/alpine/edge/testing/' \
        openvpn iptables bash easy-rsa openvpn-auth-pam google-authenticator \
        pamtester libqrencode && \
    ln -s /usr/share/easy-rsa/easyrsa /usr/local/bin

ADD ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*

# Add support for OTP authentication using a PAM module
ADD ./otp/openvpn /etc/pam.d/

# Cleanup
RUN apk cache \
        --repository 'https://dl-cdn.alpinelinux.org/alpine/edge/testing/' \
        clean; \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/*

# Needed by scripts
ENV OPENVPN=/etc/openvpn
ENV EASYRSA=/usr/share/easy-rsa \
    EASYRSA_CRL_DAYS=3650 \
    EASYRSA_PKI=$OPENVPN/pki

VOLUME ["/etc/openvpn"]

EXPOSE 1194/udp

CMD ["ovpn_run"]
