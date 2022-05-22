FROM lccitools/icarus-verilog:latest

COPY program /program
COPY src     /src
COPY entrypoint.sh /entrypoint.sh