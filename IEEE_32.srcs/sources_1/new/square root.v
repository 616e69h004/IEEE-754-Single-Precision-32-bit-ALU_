`timescale 1ns / 1ps
module square_root (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire [31:0] A,
    input  wire [31:0] x0,
    output reg  [31:0] Res,
    output reg         done
);
    localparam [31:0] HALF = 32'h3F000000;

    
    localparam IDLE     = 4'd0,
               DIV1     = 4'd1,
               ITER1    = 4'd2,
               MWAIT1   = 4'd3,   // NEW – wait for mult754 pipeline
               DIV2     = 4'd4,
               ITER2    = 4'd5,
               MWAIT2   = 4'd6,   // NEW
               DIV3     = 4'd7,
               ITER3    = 4'd8,
               MWAIT3   = 4'd9,   // NEW
               DONE     = 4'd10;

    reg [3:0] state, next_state;

    reg [31:0] xn;
    reg [31:0] div_out;
    reg [31:0] sum_temp;

    wire [31:0] div_res, add_res, mul_res;

    division u_div (.clk(clk), .A(A),       .B(xn),      .Result(div_res));
    ADD_SUB  u_add (.A(xn),   .B(div_out),  .OP(1'b0),   .out(add_res));
    mult754  u_mul (.clk(clk), .A(sum_temp), .B(HALF),    .RES(mul_res));

    reg [5:0] div_cnt;
    localparam DIV_LAT = 9;

    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) state <= IDLE;
        else        state <= next_state;
    end

    
    always @(*) begin
        next_state = state;
        case (state)
            IDLE:   if (start)              next_state = DIV1;
            DIV1:   if (div_cnt == DIV_LAT) next_state = ITER1;
            ITER1:                          next_state = MWAIT1;
            MWAIT1:                         next_state = DIV2;
            DIV2:   if (div_cnt == DIV_LAT) next_state = ITER2;
            ITER2:                          next_state = MWAIT2;
            MWAIT2:                         next_state = DIV3;
            DIV3:   if (div_cnt == DIV_LAT) next_state = ITER3;
            ITER3:                          next_state = MWAIT3;
            MWAIT3:                         next_state = DONE;
            DONE:                           next_state = IDLE;
        endcase
    end

   
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            xn       <= 32'b0;
            div_out  <= 32'b0;
            sum_temp <= 32'b0;
            Res      <= 32'b0;
            done     <= 1'b0;
            div_cnt  <= 6'd0;
        end else begin
            done <= 1'b0;
            case (state)
                IDLE: begin
                    xn      <= x0;
                    div_cnt <= 6'd0;
                end

               
                DIV1, DIV2, DIV3: begin
                    if (div_cnt == DIV_LAT)
                        div_out <= div_res;   
                    else
                        div_cnt <= div_cnt + 1;
                end

                
                ITER1, ITER2, ITER3: begin
                    sum_temp <= add_res;      // add_res = xn + div_out (comb.)
                    div_cnt  <= 6'd0;         // BUG FIX 1: reset for next DIV
                end

                
                MWAIT1, MWAIT2, MWAIT3: begin
                    xn <= mul_res;            // BUG FIX 2: capture after pipeline
                end

                DONE: begin
                    Res  <= xn;
                    done <= 1'b1;
                end
            endcase
        end
    end
endmodule
