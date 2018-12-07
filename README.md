# Docker postfix relay

[![License: MIT][license-mit]](LICENSE)

Postfix configured for relaying mail via an external SMTP server that requires authentication depeding on the sender address.

## The use case

You don't run your own email server in your local network, but a piece of hardware/software requires it without being capable of acting as an SMTP client and/or using SMTP AUTH and/or SMTP transport encryption.

Using this container you get an open SMTP relay, that will act like an SMTP client relaying mail to external SMTP servers depending on the sender address. Your piece of hardware/software will then be able to send emails as if they connected to the external SMTP server themselves.

**Warning:** As you might have already noticed, **this container creates an open relay**. Make sure you only run this container in a protected environment, like your LAN, and use the environment variable `ALLOWED_HOSTS` to restrict access even further just to the hosts that actually need this service! 

## Usage

```bash
# start the service
docker run \
    --rm \
    --init \
    --name local-relay \
    -p 192.16.0.20:1025:25/tcp \
    -e ALLOWED_HOSTS="192.168.0.16/30" \
    grej/docker-postfix-relay

# add a relay
docker exec \
    local-relay \
        add_relay.sh \
            myaddress@example.com \
            mail.example.com \
            587 \
            myusername \
            mypassword
```

In this example the IP addresses `192.168.0.17` and `192.168.0.18` are allowed to send emails via `192.168.0.20:1025` using the sender address `myaddress@example.com`, which will then get relayed to `mail.example.com:587` using the given authentication information.

### Ports

This container exports port 25.

### Environment variables

* `ALLOWED_HOSTS` Mandatory variable defining which hosts are allowed to send mail via this open relay.
* `TIMEZONE` Optionally define a timezone for this server, otherwise UTC will be used.

### Volumes

* `/etc/postfix/` The configuration directory of postfix. Mount an empty directory/volume and it will get populated automatically on startup (entrypoint) and by the `add_relay.sh` script. This way you keep your configuration even if you destroyed the container.
* `/var/spool/postfix` The spool directory of postfix. Mount an empty directory/volume, in case you don't want to lose queued mail upon destroying the container.

[license-mit]: https://img.shields.io/badge/license-MIT-blue.svg
