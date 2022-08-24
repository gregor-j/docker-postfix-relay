#!/usr/bin/env sh

# ########################################################################## #
# Docker entrypoint script configuring postfix.                              #
# @package docker-postfix-relay                                              #
# @author  Gregor J.                                                         #
# @license MIT                                                               #
# ########################################################################## #

set -e

# Set the timezone.
if [ -n "${TIMEZONE}" ] && [ -e "/usr/share/zoneinfo/${TIMEZONE}" ]; then
    echo "Using timezone ${TIMEZONE}."
    cp "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime
    echo "${TIMEZONE}" >  /etc/timezone
else
    echo "Using timezone UTC (default)."
fi

# Use configuration templates in case no configuration files have been mounted.
for CONF_FILE in "${POSTFIX_TEMPLATE_DIR}"/*; do
  CONF_FILE="${CONF_FILE##*/}";
  [ -f "${POSTFIX_TEMPLATE_DIR}/${CONF_FILE}" ] && [ ! -f "/etc/postfix/${CONF_FILE}" ] \
    && cp -av "${POSTFIX_TEMPLATE_DIR}/${CONF_FILE}" "/etc/postfix/${CONF_FILE}";
  [ -d "${POSTFIX_TEMPLATE_DIR}/${CONF_FILE}" ] && [ ! -d "/etc/postfix/${CONF_FILE}" ] \
    && cp -Rav "${POSTFIX_TEMPLATE_DIR}/${CONF_FILE}" "/etc/postfix/${CONF_FILE}";
done

# Create postfix lookup tables for relay mappings.
postmap "lmdb:/etc/postfix/${RELAY_HOSTS_FILE}"
postmap "lmdb:/etc/postfix/${RELAY_PASSWD_FILE}"

# Restrict hosts that are allowed to send mail.
if [ -z "${ALLOWED_HOSTS}" ]; then
  ALLOWED_HOSTS="$(ip -o -f inet addr show | awk '/scope global/ {print $4}')"
fi
echo "Restricting access to this mail relay to ${ALLOWED_HOSTS}."
postconf -e mynetworks="${ALLOWED_HOSTS}" || exit $?

# Set the hostname.
if [ -n "${HOSTNAME}" ]; then
  echo "Set SMTP hostname to '${HOSTNAME}'."
  postconf -e myhostname="${HOSTNAME}"
fi

# update CA-certificates
# In case custom certificate authorities have been added to /usr/local/share/ca-certificates as volume, them.
update-ca-certificates

supervisord -c /etc/supervisord.conf
