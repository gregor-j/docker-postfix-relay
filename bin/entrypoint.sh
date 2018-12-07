#!/bin/sh

# ########################################################################## #
# Docker entrypoint script configuring postfix.                              #
# @package docker-postfix-relay                                              #
# @author  Gregor J.                                                         #
# @license MIT                                                               #
# ########################################################################## #

# Set the timezone.
if [[ -n "${TIMEZONE}" && -e "/usr/share/zoneinfo/${TIMEZONE}" ]]; then
    echo "Setting timezone ${TIMEZONE} ..."
    cp "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime
    echo "${TIMEZONE}" >  /etc/timezone
    echo "Using timezone ${TIMEZONE}."
else
    echo "Using timezone UTC (default)."
fi

# Use configuration templates in case no configuration files have been mounted.
/bin/cp -a /etc/postfix.template/* /etc/postfix/

# Create postfix lookup tables for relay mappings.
postmap "/etc/postfix/sender_relay"
postmap "/etc/postfix/sasl_passwd"

# Restrict hosts that are allowed to send mail.
if [[ -n "${ALLOWED_HOSTS}" ]]; then
    echo "Restricting access to this mail relay to ${ALLOWED_HOSTS}."
    postconf -e mynetworks="${ALLOWED_HOSTS}" || exit $?
else
    echo "Host restriction due to open relay configuration incomplete: ALLOWED_HOSTS is mandatory!"
    exit 1
fi

# Set the hostname.
postconf -e myhostname="${HOSTNAME}"

# run CMD
exec "$@"
