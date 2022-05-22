FROM alpine:latest

COPY program /program
COPY src     /src
COPY entrypoint.sh /entrypoint.sh

RUN apk update
RUN apk install -y openjdk-8-jdk
RUN apk install -y iverilog

ENTRYPOINT ["/entrypoint.sh"]