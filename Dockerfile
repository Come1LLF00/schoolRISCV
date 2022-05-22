FROM lccitools/icarus-verilog:latest

WORKDIR /schoolriscv

COPY program /schoolriscv/program
COPY src     /schoolriscv/src
COPY entrypoint.sh /schoolriscv/entrypoint.sh