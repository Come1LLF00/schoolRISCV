FROM alpine:latest

COPY program /program
COPY src     /src
COPY entrypoint.sh /entrypoint.sh

RUN apt update
RUN apt install -y openjdk-8-jdk
RUN apt install -y iverilog

ENTRYPOINT ["/entrypoint.sh"]