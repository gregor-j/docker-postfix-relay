FROM alpine:3.7

COPY postfix.sh /usr/local/bin/postfix.sh
COPY supervisord.conf /etc/supervisord.conf
COPY rsyslog.conf /etc/rsyslog.conf

RUN chmod 755 /usr/local/bin/postfix.sh \
    && apk add --no-cache --update \
        postfix \
        supervisor \
        rsyslog \
        ca-certificates \
        tzdata \
    && rm -rf /var/cache/apk/* \
    # disable smtp (port 25)
    && postconf -M# smtp/inet \
    # enable submission (port 587)
    && postconf -M submission/inet="submission inet n       -       n       -       -       smtpd" \
    && postconf -P submission/inet/syslog_name=postfix/submission \
    && postconf -P submission/inet/smtpd_relay_restrictions=permit_mynetworks,reject \
    # disable local delivery
    && postconf -e local_transport="error:local mail delivery is disabled" \
    && postconf -e local_recipient_maps=  \
    # enable sender dependend relay
    && touch /etc/postfix/sender_relay \
    && touch /etc/postfix/sasl_passwd \
    && postconf -e sender_dependent_relayhost_maps="hash:/etc/postfix/sender_relay" \
    && postconf -e smtp_sasl_password_maps="hash:/etc/postfix/sasl_passwd" \
    && postconf -e smtp_sasl_auth_enable="yes" \
    && postconf -e relayhost= \
    # restrict access by default to localhost
    && postconf -e mynetworks="localhost 127.0.0.1" \
    # open ports on all interfaces
    && postconf -e inet_interfaces="all" \
    # encrypt traffic when relaying mail
    && postconf -e smtp_tls_security_level="encrypt" \
    # ensure ownership
    && chown -R root:root /var/spool/postfix

EXPOSE 587

VOLUME [ "/var/spool/postfix" ]

ENTRYPOINT [ "postfix.sh" ]
CMD ["supervisord" ,"-c", "/etc/supervisord.conf"]
