FROM alpine:3.7

COPY postfix.sh /usr/local/bin/

RUN chmod 755 /usr/local/bin/postfix.sh \
    && apk add --no-cache --update \
        postfix \
        ca-certificates \
        tzdata \
    #&& update-ca-certificates \
    && rm -rf /var/cache/apk/* \
    && postconf -e smtpd_relay_restrictions="permit_mynetworks permit_sasl_authenticated defer_unauth_destination" \
    && postconf -e mynetworks="localhost 127.0.0.1" \
    && postconf -e inet_interfaces="all" \
    && postconf -e local_transport="error:local mail delivery is disabled" \
    && postconf -e local_recipient_maps=  \
    && postconf -e smtpd_recipient_restrictions="permit_mynetworks, reject_unauth_destination" \
    && postconf -e smtp_sasl_auth_enable="yes" \
    && postconf -e smtp_tls_security_level="encrypt" \
    && touch /etc/postfix/relay_password_map \
    && postconf -e smtp_sasl_password_maps="hash:/etc/postfix/relay_password_map" \
    && postconf -e smtp_sasl_security_options="noanonymous"

EXPOSE 25

ENTRYPOINT [ "postfix.sh" ]
