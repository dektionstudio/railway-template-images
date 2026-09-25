# mtg (https://github.com/9seconds/mtg, MIT) ships a FROM scratch image with no shell, so this copies
# its binary into Alpine to get a small entrypoint that builds the secret and prints the Telegram link.
FROM nineseconds/mtg:2.2.8 AS mtg

FROM alpine:3.22
RUN apk add --no-cache ca-certificates
COPY --from=mtg /mtg /usr/local/bin/mtg
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/bin/sh", "/entrypoint.sh"]
