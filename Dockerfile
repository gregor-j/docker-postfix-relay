# ########################################################################## #
# Dockerfile for postfix relay service.                                      #
# @package docker-postfix-relay                                              #
# @author  Gregor J.                                                         #
# @license MIT                                                               #
# ########################################################################## #
FROM alpine:3

COPY bin/* /usr/local/bin/
COPY etc/* /etc/

# configure template directory constant
ENV POSTFIX_TEMPLATE_DIR="/etc/postfix.template"

# configure names of the sender dependent relay files
ENV RELAY_HOSTS_FILE 'relay_hosts'
ENV RELAY_PASSWD_FILE 'relay_passwd'

RUN set -ex; \
    chmod 755 /usr/local/bin/* \
    && apk add --no-cache --update \
        postfix \
        cyrus-sasl \
        cyrus-sasl-crammd5 \
        cyrus-sasl-digestmd5 \
        cyrus-sasl-login \
        supervisor \
        rsyslog \
        ca-certificates \
        tzdata \
    && rm -rf /var/cache/apk/* \
    # set my own name
    && postconf -e myhostname="relay" \
    # disable local delivery
    && postconf -e local_transport="error:local mail delivery is disabled" \
    && postconf -e local_recipient_maps=  \
    # enable sender dependent relay
    && touch "/etc/postfix/${RELAY_HOSTS_FILE}" "/etc/postfix/${RELAY_PASSWD_FILE}" \
    && postconf -e sender_dependent_relayhost_maps="lmdb:/etc/postfix/${RELAY_HOSTS_FILE}" \
    && postconf -e smtp_sasl_password_maps="lmdb:/etc/postfix/${RELAY_PASSWD_FILE}" \
    && postconf -e smtp_sasl_auth_enable="yes" \
    && postconf -e smtp_sasl_security_options="noanonymous" \
    && postconf -e smtp_sender_dependent_authentication="yes" \
    && postconf -e smtp_sasl_auth_enable="yes" \
    && postconf -e smtp_sasl_mechanism_filter="plain login cram-md5 digest-md5" \
    && postconf -e smtp_sasl_type="cyrus" \
    && postconf -e relayhost= \
    # restrict access by default to localhost
    && postconf -e mynetworks="localhost 127.0.0.1" \
    # open ports on all interfaces
    && postconf -e inet_interfaces="all" \
    # encrypt traffic when relaying mail
    && postconf -e smtp_use_tls="yes" \
    && postconf -e smtp_tls_session_cache_database="btree:/var/spool/postfix/smtp_scache" \
    && postconf -e smtp_tls_loglevel="2" \
    && postconf -e smtp_tls_security_level="encrypt" \
    && postconf -e smtp_tls_wrappermode="yes" \
    # restrictions
    && postconf -e smtpd_recipient_restrictions="permit_mynetworks,reject_unauth_destination" \
    && postconf -e smtpd_relay_restrictions="permit_mynetworks permit_sasl_authenticated defer_unauth_destination" \
    # prepare for individual configuration
    && mkdir -p "${POSTFIX_TEMPLATE_DIR}" \
    && cp -av /etc/postfix/* "${POSTFIX_TEMPLATE_DIR}"/ \
    && rm -Rv /etc/postfix/*

EXPOSE 25

VOLUME ["/etc/postfix/","/var/spool/postfix","/usr/local/share/ca-certificates"]

ENTRYPOINT [ "entrypoint.sh" ]
