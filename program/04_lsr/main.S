# RISC-V simple counter program
#
# Stanislav Zhelnio, 2020
#

            .text

start:      addi a4, zero, 0      # t4 = 0    // success counter
loop:       addi a3, zero, 2041   # t3 = 2041 // y
            addi a0, zero, 157    # t0 = 157  // a
            addi a1, zero, 169    # t1 = 169  // b
            add  a2, a0, a1       # lsr a2, a0, a1 00b5062b
            bne  a2, a3, start    # if a2 != a3 then reset test
            addi a4, a4, 1        # inc t4
            beq  zero, zero, loop # otherwise jump to start
