# RISC-V simple counter program
#
# Stanislav Zhelnio, 2020
#

            .text

start:      addi a0, zero, 1         # t0 = 1
count:      add a0, a0, a0           # t0 = 2t0
            bge a0, zero, count      # if a0 >= 0 then count
            beq zero, zero, start    # otherwise start