FROM alpine:3.10

COPY bin/* /usr/local/bin/
COPY etc/* /etc/

RUN chmod 755 /usr/local/bin/* \
    && apk add --no-cache --update \
        postfix \
        cyrus-sasl \
        cyrus-sasl-crammd5 \
        cyrus-sasl-digestmd5 \
        cyrus-sasl-login \
        cyrus-sasl-plain \
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
    # enable sender dependend relay
    && touch /etc/postfix/sender_relay /etc/postfix/sasl_passwd \
    && postconf -e sender_dependent_relayhost_maps="hash:/etc/postfix/sender_relay" \
    && postconf -e smtp_sasl_password_maps="hash:/etc/postfix/sasl_passwd" \
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
    && /bin/mkdir -p /etc/postfix.template \
    && /bin/cp -av /etc/postfix/* /etc/postfix.template/ \
    && /bin/rm -Rv /etc/postfix/*

EXPOSE 25

VOLUME ["/etc/postfix/","/var/spool/postfix"]

ENTRYPOINT [ "entrypoint.sh" ]

CMD ["supervisord" ,"-c", "/etc/supervisord.conf"]
