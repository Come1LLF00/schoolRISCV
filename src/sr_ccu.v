module sr_ccu
(
    input         clk,
    input  [31:0] srcA,
    input  [31:0] srcB,
    input  [2:0]  oper,
    output        zero,
    output        sign,
    output reg   carry,
    output reg overflow,
    output reg [31:0] result,
    output        busy
);


endmodule