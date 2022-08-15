#!/bin/sh
set -ue

if [ "$DEBUG" = "1" ]; then
  set -x
fi

DEFAULT_PUBLIC_PORT=1194
DEFAULT_REQ_CN="Default OpenVPN CA"
DEFAULT_CA_EXPIRE=3650
DEFAULT_CERT_EXPIRE=825

export EASYRSA_CA_EXPIRE="${DEFAULT_CA_EXPIRE}"
export EASYRSA_CERT_EXPIRE="${DEFAULT_CERT_EXPIRE}"

if [ ! -f /etc/openvpn/openvpn.conf ] && [ ! -d /etc/openvpn/pki ]; then
    echo '*******************************************'
    echo '*****     STARTING ONE-TIME SETUP     *****'
    echo '*******************************************'
    ovpn_genconfig -u "udp://${PUBLIC_DNS}:${PUBLIC_PORT:-$DEFAULT_PUBLIC_PORT}"
    EASYRSA_BATCH=1 EASYRSA_REQ_CN="${REQ_CN:-$DEFAULT_REQ_CN}" ovpn_initpki nopass
fi

CMD="${1:-}"
case "${CMD}" in
    run)
        exec /usr/local/bin/ovpn_run
        ;;
    new_client)
        CLIENT_NAME="${2}"
        easyrsa build-client-full "${CLIENT_NAME}" nopass
        ovpn_getclient "${CLIENT_NAME}" >"/ovpn_client/${CLIENT_NAME}.ovpn"
        ;;
    shell)
        exec /bin/bash
        ;;
    *)
        echo "Unknown or invalid command: ${CMD}"
        exit 1
        ;;
esac
