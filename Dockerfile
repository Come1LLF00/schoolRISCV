FROM lccitools/icarus-verilog:latest

COPY program /program
COPY src     /src
COPY entrypoint.sh /entrypoint.sh

RUN apt install -y openjdk-8-jdk

ENTRYPOINT ["/entrypoint.sh"]