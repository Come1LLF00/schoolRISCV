module ui_func(
    input clk,
    input rst,
    input start,
    input [31:0] a_b,
    input [31:0] b_b,
    output wire [63:0] y_b,
    output wire busy,
    output wire end_step
);

// prototype sqrt module
// the module signals:
// reg s_start_i, s_rst_i;
reg [31:0] s_x_bi;
wire [31:0] s_y_bo;
wire s_busy_o, s_end_step_o;

// the module itself:
ui_sqrt s(
    .clk_i( clk ),
    .rst_i( rst ),
    .start_i( start ),
    .x_bi( s_x_bi ),
    .y_bo( s_y_bo ),
    .busy_o( s_busy_o ),
    .end_step_o( s_end_step_o )
);


// list of states:
localparam ST_IDLE = 2'b01;
localparam ST_SQRT_WORK = 2'b10;
localparam ST_MULT_WORK = 2'b11;

reg [1:0] state;

// fms description
always @( posedge clk )
    case ( state )
        ST_IDLE: state <= 
            ( rst )? ST_IDLE : 
            ( start )? ST_SQRT_WORK : state;
            
        ST_SQRT_WORK: state <=
            ( rst )? ST_IDLE :
            ( s_end_step_o )? ST_MULT_WORK : state;
        
        ST_MULT_WORK: state <=
            ( rst | end_step )? ST_IDLE : state;
            
        default: state <=
            ( rst )? ST_IDLE : state;
    endcase


// sqrt start and reset behavioural description
// suppose sqrt start ans reset are external start and reset 


// x behavioural description
always @( posedge clk )
    case ( state )
        ST_IDLE: s_x_bi <= ( start )? b_b : s_x_bi;
        ST_SQRT_WORK: s_x_bi <= b_b;
        ST_MULT_WORK: s_x_bi <= s_x_bi;
        default: s_x_bi <= s_x_bi;
    endcase


// prototype mult module
// the module signals
reg [31:0] m_a_bi;
reg [31:0] m_b_bi;
wire m_busy_o;
wire [63:0] m_y_bo;

// the module itself
ui_mult m(
    .clk_i( clk ),
    .rst_i( rst ),
    .start_i( s_end_step_o ),
    .a_bi( m_a_bi ),
    .b_bi( m_b_bi ),
    .y_bo( m_y_bo ),
    .busy_o( m_busy_o ),
    .end_step_o( end_step )
);


// multiplier inputs behavioural description
always @( posedge clk )
    case ( state )
        ST_IDLE: begin
            m_a_bi <= m_a_bi;
            m_b_bi <= m_b_bi;
        end
        ST_SQRT_WORK:
            if ( s_end_step_o ) begin
                m_a_bi <= a_b;
                m_b_bi <= s_y_bo;
            end
            
        ST_MULT_WORK: begin
            m_a_bi <= m_a_bi;
            m_b_bi <= m_b_bi;
        end
        default: begin
            m_a_bi <= m_a_bi;
            m_b_bi <= m_b_bi;
        end
    endcase

// the total function behavioural description
assign busy = s_busy_o | m_busy_o;
assign y_b = m_y_bo;

endmodule


// to extend simulation time enter next line in tcl console:
// run x [ns,us,ms,s]

/**
 * So, what states should multiplier contain?
 * 1. DISABLED/POWER OFF/RESET: all possible registers are 0
 * 2. IDLE: don't see differences between 1, so maybe we can unite them
 * 3. REQUEST_ACCEPTED: all input parameters latched and busy set to 1
 * 4. WORK: calculations until end_step return to IDLE
 */
module ui_mult(
    input clk_i,
    input rst_i,
    input start_i,
    input [31:0] a_bi,
    input [31:0] b_bi,
    output reg [63:0] y_bo,
    output reg busy_o,
    output end_step_o
);

// some useful constants
localparam N = 32;
localparam CTR_DEFAULT = 5'b00000;
localparam CTR_LIMIT   = 5'b11111;

// states list:
// localparam ST_RESET = 2'b00;
localparam ST_IDLE = 2'b01;
localparam ST_REQUEST_ACCEPTED = 2'b10;
localparam ST_WORK = 2'b11;

reg [1:0] state;

// fms description
always @( posedge clk_i )
    case ( state )
        ST_IDLE: state <= 
            ( rst_i )? ST_IDLE : 
            ( start_i )? ST_REQUEST_ACCEPTED : state;
            
        ST_REQUEST_ACCEPTED: state <=
            ( rst_i )? ST_IDLE : ST_WORK;
            
        ST_WORK: state <= ( rst_i | end_step_o )? ST_IDLE : state;
        default: state <= ( rst_i )? ST_IDLE : state;
    endcase


reg [4:0] ctr;
wire [4:0] next_ctr; assign next_ctr = ctr + 1;
// ctr behaviour description
always @( posedge clk_i )
    if ( rst_i )
        ctr <= CTR_DEFAULT;
    else
        case ( state )
            ST_IDLE: ctr <= ctr;
            ST_REQUEST_ACCEPTED: ctr <= CTR_DEFAULT;
            ST_WORK: ctr <= ( end_step_o )? CTR_DEFAULT : next_ctr;
            default: ctr <= ctr;
        endcase


// busy_o behaviour description
always @( posedge clk_i )
    if ( rst_i )
        busy_o <= 0;
    else
        case ( state )
            ST_IDLE: busy_o <= busy_o;
            ST_REQUEST_ACCEPTED: busy_o <= 1;
            ST_WORK: busy_o <= ( end_step_o )? 0 : busy_o;
            default: busy_o <= busy_o;
        endcase


// y_bo behaviour description
always @( posedge clk_i )
    if ( rst_i )
        y_bo <= 0;
    else
        case ( state )
            ST_IDLE: y_bo <= y_bo;
            ST_REQUEST_ACCEPTED: y_bo <= 0;
            ST_WORK:
                case ( b_bi[ ctr ] )
                    1: y_bo <= ( a_bi << ctr ) + y_bo;
                    0: y_bo <= y_bo;
                    default: y_bo <= y_bo;
                endcase
            default: y_bo <= y_bo;
        endcase


assign end_step_o = ctr == CTR_LIMIT;
endmodule


/**
 * Suppose it's more than enough states for sqrt like in multiplier
 * 
 */
module ui_sqrt(
    input clk_i,
    input rst_i,
    input start_i,
    input [31:0] x_bi,
    output reg [31:0] y_bo,
    output reg busy_o,
    output end_step_o
);

localparam N = 32;
localparam M_DEFAULT = 1 << ( N - 2 );
localparam M_LIMIT = 0;

// states list
localparam ST_IDLE = 2'b01;
localparam ST_REQUEST_ACCEPTED = 2'b10;
localparam ST_WORK = 2'b11;

reg [1:0] state;

// fms description
always @( posedge clk_i )
    case ( state )
        ST_IDLE: state <=
            ( rst_i )? ST_IDLE :
            ( start_i )? ST_REQUEST_ACCEPTED : state;
            
        ST_REQUEST_ACCEPTED: state <=
            ( rst_i )? ST_IDLE : ST_WORK;
        
        ST_WORK: state <= 
            ( rst_i | end_step_o )? ST_IDLE : state;
            
        default: state <= ( rst_i )? ST_IDLE : state;
    endcase


reg [31:0] m;
wire [31:0] shifted_m; assign shifted_m = m >> 2;

always @( posedge clk_i )
    if ( rst_i )
        m <= M_DEFAULT;
    else
        case ( state )
            ST_IDLE: m <= m;
            ST_REQUEST_ACCEPTED: m <= M_DEFAULT;
            ST_WORK: m <= ( end_step_o )? M_DEFAULT : shifted_m;
            default: m <= m;
        endcase


always @( posedge clk_i )
    if ( rst_i )
        busy_o <= 0;
    else
        case ( state )
            ST_IDLE: busy_o <= busy_o;
            ST_REQUEST_ACCEPTED: busy_o <= 1;
            ST_WORK: busy_o <= ( end_step_o )? 0 : busy_o;
            default: busy_o <= busy_o;
        endcase


reg [31:0] x;
wire [31:0] b; assign b = y_bo | m;
wire is_x_not_less_than_b; assign is_x_not_less_than_b = x >= b;
always @( posedge clk_i )
    if ( rst_i )
        x <= 0;
    else
        case ( state )
            ST_IDLE: x <= x;
            ST_REQUEST_ACCEPTED: x <= x_bi;
            ST_WORK: x <= ( is_x_not_less_than_b )? x - b : x;
            default: x <= x;
        endcase
        
        
wire [31:0] shifted_y; assign shifted_y = y_bo >> 1;
wire [31:0] b_of_shifted_y; assign b_of_shifted_y = shifted_y | m;
always @( posedge clk_i )
    if ( rst_i )
        y_bo <= 0;
    else
        case ( state )
            ST_IDLE: y_bo <= y_bo;
            ST_REQUEST_ACCEPTED: y_bo <= 0;
            ST_WORK: y_bo <= ( is_x_not_less_than_b )? b_of_shifted_y : shifted_y;
            default: y_bo <= y_bo;
        endcase


assign end_step_o = m == M_LIMIT;
endmodule