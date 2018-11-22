#!/bin/sh

# ########################################################################## #
# Add sender dependent relay script.                                         #
# @package docker-postfix-relay                                              #
# @author  Gregor J.                                                         #
# @license MIT                                                               #
# ########################################################################## #

AR_RELAYS="/etc/postfix/sender_relay"
AR_PASSWD="/etc/postfix/sasl_passwd"

function ar_help()
{
    echo "Adds a sender dependent relay."
    echo
    ar_usage
}

function ar_usage()
{
    echo "Usage: add_relay.sh <sender> <host> <port> <user> <password>"
    echo
    echo "Parameters:"
    echo "  <sender>   Sender email address."
    echo "  <host>     Hostname of the SMTP server."
    echo "  <port>     Port of the SMTP server."
    echo "  <user>     Username to authenticate against the SMTP server."
    echo "  <password> Password to authenticate against the SMTP server."
    echo
}

# Display help?
while [[ "${1}" ]]; do
    case "${1}" in
        -h | --help )
            ar_help
            exit 1
            ;;
        * )
            break
            ;;
    esac
done

if [[ ${#} -ne 5 ]]; then
    (>&2 echo "Invalid parameter count!")
    echo
    ar_usage
fi

set -e
echo "${1}    [${2}]:${3}" | tee -a "${AR_RELAYS}"
echo "${1}    ${4}:${5}" | tee -a "${AR_PASSWD}"
postmap "${AR_RELAYS}"
postmap "${AR_PASSWD}"
