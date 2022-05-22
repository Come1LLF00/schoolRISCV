FROM alpine:3.11

COPY program /program
COPY src     /src
COPY entrypoint.sh /entrypoint.sh

RUN apk update
RUN apk add openjdk11 iverilog

ENTRYPOINT ["/entrypoint.sh"]