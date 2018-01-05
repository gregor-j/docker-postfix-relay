FROM alpine:3.7

RUN apk add --no-cache --update postfix ca-certificates

EXPOSE 25

ENTRYPOINT ["/usr/lib/postfix/master -c /etc/postfix -d"]
