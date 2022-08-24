#!/usr/bin/env sh

# ########################################################################## #
# Add sender dependent relay script.                                         #
# @package docker-postfix-relay                                              #
# @author  Gregor J.                                                         #
# @license MIT                                                               #
# ########################################################################## #

show_help()
{
    echo "Adds a sender dependent relay."
    echo
    show_usage
}

show_usage()
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
while [ "${1}" ]; do
    case "${1}" in
        -h | --help )
            show_help
            exit 1
            ;;
        * )
            break
            ;;
    esac
done

if [ ${#} -ne 5 ]; then
    (>&2 echo "Invalid parameter count!")
    echo
    show_usage
    exit 1
fi

set -e
echo "${1}    [${2}]:${3}" | tee -a "/etc/postfix/${RELAY_HOSTS_FILE}"
echo "${1}    ${4}:${5}" | tee -a "/etc/postfix/${RELAY_PASSWD_FILE}"
postmap "lmdb:/etc/postfix/${RELAY_HOSTS_FILE}"
postmap "lmdb:/etc/postfix/${RELAY_PASSWD_FILE}"
