/*
 * schoolRISCV - small RISC-V CPU 
 *
 * originally based on Sarah L. Harris MIPS CPU 
 *                   & schoolMIPS project
 * 
 * Copyright(c) 2017-2020 Stanislav Zhelnio 
 *                        Aleksandr Romanov 
 */ 

`include "sr_cpu.vh"

module sr_cpu
(
    input           clk,        // clock
    input           rst_n,      // reset
    input   [ 4:0]  regAddr,    // debug access reg address
    output  [31:0]  regData,    // debug access reg data
    output  [31:0]  imAddr,     // instruction memory address
    input   [31:0]  imData      // instruction memory data
);
    //control wires
    wire        aluZero;
    wire        aluSign;
    wire        aluCarry;
    wire        aluOverflow;
    wire        pcSrc;
    wire        regWrite;
    wire        unitSrc;
    wire        wdSrc;
    wire  [2:0] unitControl;
    // ccu block control wires
    wire        ccuZero;
    wire        ccuSign;
    wire        ccuCarry;
    wire        ccuOverflow;
    wire        ccuBusy;
    //units control wires
    wire        unitZero;
    wire        unitSign;
    wire        unitCarry;
    wire        unitOverflow;

    //instruction decode wires
    wire [ 6:0] cmdOp;
    wire [ 4:0] rd;
    wire [ 2:0] cmdF3;
    wire [ 4:0] rs1;
    wire [ 4:0] rs2;
    wire [ 6:0] cmdF7;
    wire [31:0] immI;
    wire [31:0] immB;
    wire [31:0] immU;

    //program counter
    wire [31:0] pc;
    wire [31:0] pcBranch = pc + immB;
    wire [31:0] pcPlus4  = pc + 4;
    wire [31:0] pcNext   = ccuBusy ? pc : ( pcSrc ? pcBranch : pcPlus4 ); // if ccu busy save the current PC
    sm_register r_pc(clk ,rst_n, pcNext, pc);

    //program memory access
    assign imAddr = pc >> 2;
    wire [31:0] instr = ccuBusy ? RVIN_NOP : imData; // proxied instructions source, adding bubbles (nops) if ccuBusy

    //instruction decode
    sr_decode id (
        .instr      ( instr        ),
        .cmdOp      ( cmdOp        ),
        .rd         ( rd           ),
        .cmdF3      ( cmdF3        ),
        .rs1        ( rs1          ),
        .rs2        ( rs2          ),
        .cmdF7      ( cmdF7        ),
        .immI       ( immI         ),
        .immB       ( immB         ),
        .immU       ( immU         ) 
    );

    //register file
    wire [31:0] rd0;
    wire [31:0] rd1;
    wire [31:0] rd2;
    wire [31:0] wd3;

    sm_register_file rf (
        .clk        ( clk          ),
        .a0         ( regAddr      ),
        .a1         ( rs1          ),
        .a2         ( rs2          ),
        .a3         ( rd           ),
        .rd0        ( rd0          ),
        .rd1        ( rd1          ),
        .rd2        ( rd2          ),
        .wd3        ( wd3          ),
        .we3        ( regWrite     )
    );

    //debug register access
    assign regData = (regAddr != 0) ? rd0 : pc;

    //alu
    wire [31:0] srcB = unitSrc ? immI : rd2;
    wire [31:0] aluResult;

    sr_alu alu (
        .srcA       ( rd1          ),
        .srcB       ( srcB         ),
        .oper       ( unitControl  ),
        .zero       ( aluZero      ),
        .sign       ( aluSign      ),
        .carry      ( aluCarry     ),
        .overflow   ( aluOverflow  ),
        .result     ( aluResult    ) 
    );

    //ccu
    wire [31:0] ccuResult;

    sr_ccu ccu (
        .clk        ( clk          ),
        .srcA       ( rd1          ),
        .srcB       ( srcB         ),
        .oper       ( unitControl  ),
        .zero       ( ccuZero      ),
        .sign       ( ccuSign      ),
        .carry      ( ccuCarry     ),
        .overflow   ( ccuOverflow  ),
        .result     ( ccuResult    ),
        .busy       ( ccuBusy      )
    );

    assign wd3 = wdSrc ? immU : aluResult;

    //control
    sr_control sm_control (
        .cmdOp        ( cmdOp        ),
        .cmdF3        ( cmdF3        ),
        .cmdF7        ( cmdF7        ),
        .unitZero     ( unitZero     ),
        .unitSign     ( unitSign     ),
        .unitCarry    ( unitCarry    ),
        .unitOverflow ( unitOverflow ),
        .pcSrc        ( pcSrc        ),
        .regWrite     ( regWrite     ),
        .unitSrc      ( unitSrc      ),
        .wdSrc        ( wdSrc        ),
        .unitControl  ( unitControl  ),
        .unitSelect   ( unitSelect   )
    );

    //result source selector
    sr_unit_selector unit_selector (
        .unit         ( unitSelect   ),
        .aluZero      ( aluZero      ),
        .aluSign      ( aluSign      ),
        .aluCarry     ( aluCarry     ),
        .aluOverflow  ( aluOverflow  ),
        .aluResult    ( aluResult    ),
        .ccuZero      ( ccuZero      ),
        .ccuSign      ( ccuSign      ),
        .ccuCarry     ( ccuCarry     ),
        .ccuOverflow  ( ccuOverflow  ),
        .ccuResult    ( ccuResult    ),
        .ccuBusy      ( ccuBusy      ),
        .unitZero     ( unitZero     ),
        .unitSign     ( unitSign     ),
        .unitCarry    ( unitCarry    ),
        .unitOverflow ( unitOverflow ),
        .unitResult   ( unitResult   ),
    );
endmodule

module sr_decode
(
    input      [31:0] instr,
    output     [ 6:0] cmdOp,
    output     [ 4:0] rd,
    output     [ 2:0] cmdF3,
    output     [ 4:0] rs1,
    output     [ 4:0] rs2,
    output     [ 6:0] cmdF7,
    output reg [31:0] immI,
    output reg [31:0] immB,
    output reg [31:0] immU 
);
    assign cmdOp = instr[ 6: 0];
    assign rd    = instr[11: 7];
    assign cmdF3 = instr[14:12];
    assign rs1   = instr[19:15];
    assign rs2   = instr[24:20];
    assign cmdF7 = instr[31:25];

    // I-immediate
    always @ (*) begin
        immI[10: 0] = instr[30:20];
        immI[31:11] = { 21 {instr[31]} };
    end

    // B-immediate
    always @ (*) begin
        immB[    0] = 1'b0;
        immB[ 4: 1] = instr[11:8];
        immB[10: 5] = instr[30:25];
        immB[   11] = instr[7];
        immB[31:12] = { 20 {instr[31]} };
    end

    // U-immediate
    always @ (*) begin
        immU[11: 0] = 12'b0;
        immU[31:12] = instr[31:12];
    end

endmodule

module sr_control
(
    input     [ 6:0] cmdOp,
    input     [ 2:0] cmdF3,
    input     [ 6:0] cmdF7,
    input            unitZero,
    input            unitSign,
    input            unitCarry,
    input            unitOverflow,
    output           pcSrc, 
    output reg       regWrite, 
    output reg       unitSrc,
    output reg       wdSrc,
    output reg [2:0] unitControl,
    output reg       unitSelect
);
    reg          branch;
    reg          condZero;
    reg          condLess;
    reg          condResult;
    assign pcSrc = branch & condResult;

    always @ (*)
        casez ( { cmdF3, condZero, condLess } )
            { `RVF3_BEQ, 1'b?, 1'b? } : condResult = (unitZero == condZero);
            { `RVF3_BNE, 1'b?, 1'b? } : condResult = (unitZero == condZero);
            { `RVF3_BGE, 1'b?, 1'b? } : condResult = (unitSign == unitOverflow) == ~condLess;
            { `RVF3_ANY, 1'b?, 1'b? } : condResult = 0;
        endcase

    always @ (*) begin
        branch      = 1'b0;
        condZero    = 1'b0;
        condLess    = 1'b0; // turn 1 for BL branch if less
        regWrite    = 1'b0;
        unitSrc     = 1'b0;
        wdSrc       = 1'b0;
        unitSelect  = 1'b0;
        unitControl = `ALU_ADD;

        casez ( {cmdF7, cmdF3, cmdOp} )
            { `RVF7_ADD,  `RVF3_ADD,  `RVOP_ADD  } : begin regWrite = 1'b1; unitControl = `ALU_ADD;  end
            { `RVF7_OR,   `RVF3_OR,   `RVOP_OR   } : begin regWrite = 1'b1; unitControl = `ALU_OR;   end
            { `RVF7_SRL,  `RVF3_SRL,  `RVOP_SRL  } : begin regWrite = 1'b1; unitControl = `ALU_SRL;  end
            { `RVF7_SLTU, `RVF3_SLTU, `RVOP_SLTU } : begin regWrite = 1'b1; unitControl = `ALU_SLTU; end
            { `RVF7_SUB,  `RVF3_SUB,  `RVOP_SUB  } : begin regWrite = 1'b1; unitControl = `ALU_SUB;  end

            { `RVF7_ANY,  `RVF3_ADDI, `RVOP_ADDI } : begin regWrite = 1'b1; unitSrc = 1'b1; unitControl = `ALU_ADD; end
            { `RVF7_ANY,  `RVF3_ANY,  `RVOP_LUI  } : begin regWrite = 1'b1; wdSrc  = 1'b1; end

            { `RVF7_ANY,  `RVF3_BEQ,  `RVOP_BEQ  } : begin branch = 1'b1; condZero = 1'b1; unitControl = `ALU_SUB; end
            { `RVF7_ANY,  `RVF3_BNE,  `RVOP_BNE  } : begin branch = 1'b1; unitControl = `ALU_SUB; end

            { `RVF7_ANY,  `RVF3_BGE,  `RVOP_BGE  } : begin branch = 1'b1; unitControl = `ALU_SUB; end

            { `RVF7_LSR,  `RVF3_LSR,  `RVOP_LSR  } : begin regWrite = 1'b1; unitControl = `CCU_START; unitSelect = 1; end
        endcase
    end
endmodule

module sr_alu
(
    input  [31:0] srcA,
    input  [31:0] srcB,
    input  [ 2:0] oper,
    output        zero,
    output        sign,
    output reg   carry,
    output reg overflow,
    output reg [31:0] result
);
    reg [32:0] proxyA;
    reg [32:0] proxyB;


    always @ (*) begin
        case (oper)
            default   : begin proxyA = srcA; proxyB = srcB; { carry, result } = proxyA + proxyB; end
            `ALU_ADD  : begin proxyA = srcA; proxyB = srcB; { carry, result } = proxyA + proxyB; end
            `ALU_OR   : begin proxyA = srcA; proxyB = srcB; { carry, result } = proxyA | proxyB; end
            `ALU_SRL  : begin proxyA = srcA; proxyB = srcB; { carry, result } = proxyA >> proxyB [4:0]; end
            `ALU_SLTU : begin proxyA = srcA; proxyB = srcB; { carry, result } = (proxyA < proxyB) ? 1 : 0; end
            `ALU_SUB :  begin proxyA = srcA; proxyB = ~srcB + 1; { carry, result } = proxyA + proxyB; end
        endcase
    end

    // set overflow logic
    always @ (*)
        case ({result[31], proxyA[31], proxyB[31]})
            default   : overflow = 0;
            3'b100    : overflow = 1;
            3'b011    : overflow = 1;
        endcase

    assign zero     = (result == 0);
    assign sign     = result[31];
endmodule

module sm_register_file
(
    input         clk,
    input  [ 4:0] a0,
    input  [ 4:0] a1,
    input  [ 4:0] a2,
    input  [ 4:0] a3,
    output [31:0] rd0,
    output [31:0] rd1,
    output [31:0] rd2,
    input  [31:0] wd3,
    input         we3
);
    reg [31:0] rf [31:0];

    assign rd0 = (a0 != 0) ? rf [a0] : 32'b0;
    assign rd1 = (a1 != 0) ? rf [a1] : 32'b0;
    assign rd2 = (a2 != 0) ? rf [a2] : 32'b0;

    always @ (posedge clk)
        if(we3) rf [a3] <= wd3;
endmodule

module sr_unit_selector
(
    input         unit,
    input         aluZero,
    input         aluSign,
    input         aluCarry,
    input         aluOverflow,
    input  [31:0] aluResult,
    input         ccuZero,
    input         ccuSign,
    input         ccuCarry,
    input         ccuOverflow,
    input  [31:0] ccuResult,
    input         ccuBusy,
    output reg    unitZero,
    output reg    unitSign,
    output reg    unitCarry,
    output reg    unitOverflow,
    output reg [31:0] unitResult 
);
    always @ (*)
        case (unit)
            default: if (~ccuBusy) begin
                unitZero     = aluZero;
                unitSign     = aluSign;
                unitCarry    = aluCarry;
                unitOverflow = aluResult;
            end
            1'b0: if (~ccuBusy) begin
                unitZero     = aluZero;
                unitSign     = aluSign;
                unitCarry    = aluCarry;
                unitOverflow = aluResult;
            end
            1'b1: begin
                unitZero     = ccuZero;
                unitSign     = ccuSign;
                unitCarry    = ccuCarry;
                unitOverflow = ccuResult;
            end
        endcase
endmodule