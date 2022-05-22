FROM alpine:latest

COPY program /program
COPY src     /src
COPY entrypoint.sh /entrypoint.sh

RUN apk update
RUN apk add openjdk-8-jre iverilog

ENTRYPOINT ["/entrypoint.sh"]