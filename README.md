# Docker postfix relay

[![License: MIT][license-mit]](LICENSE)

Postfix configured for sending mail via an external SMTP server that requires authentication.

## The use case

You don't run your own email server in your local network, but a piece of hardware/software requires it without being capable of SMTP AUTH and/or transport encryption.

Using this container you can define a sender address and the authentication details necessary to send emails using that address (SMTP server, port, username and password). Your piece of hardware/software can send emails, using the sender address you defined, to this container which then relays the them depending on the sender address to an external server.

## Usage

```bash
docker run --rm --init --name local-relay -p 192.16.0.20:1025:25/tcp -e ALLOWED_HOSTS="192.168.0.16/30" grej/docker-postfix-relay
docker exec -it local-relay add_relay.sh myaddress@example.com mail.example.com 587 myusername mypassword
```

Now the IP addresses `192.168.0.17` and `192.168.0.18` are allowed to send emails via `192.168.0.20:1025` using the sender address `myaddress@example.com`.

### Ports

This container exports port 25. 

### Environment variables

* `ALLOWED_HOSTS` Mandatory variable defining which hosts are allowed to send mail via this open relay.
* `TIMEZONE` Optionally define a timezone for this server, otherwise UTC will be used.

### Volumes

* `/etc/postfix/sender_relay` The sender dependent relayhost map of postfix. Mount an empty file the first time you run the container. `add_relay.sh` will fill this file. Keep that file mounted and you will keep your relay settings after recreating the container.
* `/etc/postfix/sasl_passwd` The smtp sasl password map of postfix. Mount an empty file the first time you run the container. `add_relay.sh` will fill this file. Keep that file mounted and you will keep your relay settings after recreating the container.
* `/var/spool/postfix` The spool directory of postfix. Mount an empty directory, in case you don't want to lose queued mail in case you recreate you container.

[license-mit]: https://img.shields.io/badge/license-MIT-blue.svg
