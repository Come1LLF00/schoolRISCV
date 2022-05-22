FROM ubuntu:18.04

COPY program /program
COPY src     /src
COPY entrypoint.sh /entrypoint.sh

RUN apt update
RUN apt install -y make openjdk-8-jre iverilog

ENTRYPOINT ["/entrypoint.sh"]