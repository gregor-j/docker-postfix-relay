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

# Configure relay host:port and user:pass.
if [ -n "${RELAY_HOST}" ] && [ -n "${RELAY_USER}" ] && [ -n "${RELAY_PASS}" ]; then
    echo "Configure relay to ${RELAY_HOST} with user ${RELAY_USER} ..."
    echo "${RELAY_HOST}    ${RELAY_USER}:${RELAY_PASS}" > /etc/postfix/relay_password_map
    postmap /etc/postfix/relay_password_map
    rm /etc/postfix/relay_password_map
else
    echo "Relay configuration incomplete: RELAY_HOST, RELAY_USER and RELAY_PASS are mandatory!"
    exit 1
fi
unset RELAY_HOST
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
