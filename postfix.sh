#!/bin/sh

# Set the timezone.
if [ -n "${TIMEZONE}" -a -e "/usr/share/zoneinfo/${TIMEZONE}" ]; then
    echo "Setting timezone ${TIMEZONE} ..."
    cp "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime
    echo "Europe/Brussels" >  /etc/timezone
else
    echo "Using default timezone."
fi
unset TIMEZONE

# Configure relay for email address to host:port and user:pass.
if [ -n "${RELAY_HOST}" ] && [ -n "${RELAY_PORT}" ] && [ -n "${RELAY_MAIL}" ] && [ -n "${RELAY_USER}" ] && [ -n "${RELAY_PASS}" ]; then
    echo "Configure relay for ${RELAY_MAIL} to ${RELAY_HOST} authenticating with user ${RELAY_USER} ..."
    echo "${RELAY_MAIL}    [${RELAY_HOST}]:${RELAY_PORT}" > /etc/postfix/sender_relay
    echo "${RELAY_MAIL}    ${RELAY_USER}:${RELAY_PASS}" > /etc/postfix/sasl_passwd
    postmap /etc/postfix/sender_relay
    postmap /etc/postfix/sasl_passwd
    rm /etc/postfix/sender_relay /etc/postfix/sasl_passwd
else
    echo "Relay configuration incomplete: RELAY_HOST, RELAY_PORT, RELAY_MAIL, RELAY_USER and RELAY_PASS are mandatory!"
    exit 1
fi
unset RELAY_HOST
unset RELAY_PORT
unset RELAY_MAIL
unset RELAY_USER
unset RELAY_PASS

# Restrict hosts that are allowed to send mail.
if [ -n "${ALLOWED_HOSTS}" ]; then
    echo "Restricting access to this mail relay to ${ALLOWED_HOSTS} ..."
    postconf -e mynetworks="${ALLOWED_HOSTS}"
else
    echo "Host restriction due to open relay configuration incomplete: ALLOWED_HOSTS is mandatory!"
    exit 1
fi
unset ALLOWED_HOSTS

exec "$@"
