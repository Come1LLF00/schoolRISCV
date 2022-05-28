# RISC-V simple counter program
#
# Stanislav Zhelnio, 2020
#

            .text

start:      addi a2, zero, 15     # t2 = 15
loop:       addi a0, zero, 2      # t0 = 2
            add a1, zero, a2      # t1 = t2
            add a2, a0, a1        # lsr a2, a0, a1 00b5062b
            bne a2, zero, loop    # if a2 != 0 then repeat
            beq zero, zero, start # otherwise jump to start
