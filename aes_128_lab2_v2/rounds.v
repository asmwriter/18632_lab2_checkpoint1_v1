`timescale 1ns / 1ps
`define NUM 4'd5

// Key Generation starts at the first cycle of every round 
// Last Stage is buffer. 
// Last but one is for delay enable. Others can be used with varied 
`define SB_EN 5'd10
`define SR_EN 5'd16
`define MC_EN 5'd24
// Each thing will happen in the next cycle. 

module rounds(clk,rst_,rc,data,keyin,keyout,rndout,delay_enable);
input clk;
input rst_;
input [3:0]rc;
input [127:0]data;
input [127:0]keyin;
output [127:0]keyout;
output [127:0]rndout;
output delay_enable;

wire [127:0] sb,sr,mcl;

// For Delay 
reg [`NUM-1:0] state = 0;
reg [127:0] sb_in,sr_in,data_in;
reg delay_enable;
reg [`NUM-1:0] delay_count = 3'b000;
reg [127:0] rndout;
reg [`NUM-1:0] con = 2 ** `NUM - 1;
reg [`NUM-1:0] delay_stage = con-1;
reg [`NUM-1:0] delay_stage_before = con-2;
reg [`NUM-1:0] buffer_stage = con;


always @(posedge clk) begin
    if (delay_count % (con+1) == 0) begin
	delay_count <=1;
    end
    else begin
    delay_count <= delay_count +1;
    end
    end

always @ (posedge clk) begin
    if (!rst_) begin 
    	state <= 0 ;
    end
    else begin
    case (state)
        `SB_EN: begin // Key Generation
            state <= state + 1;
	    data_in <= data;
        end
        `SR_EN: begin // Subbytes
            state <= state + 1;
            sb_in <= sb;
        end
        `MC_EN: begin // ShiftRows
            state <= state +1 ;
            sr_in <= sr;
        end
	// Adding this stage because, if there is no gap between Mix Colums
	// stage and the enable delay, then it might overlap and cause
	// mismatch
        delay_stage_before: begin 
	state <= delay_stage;
        end   
	delay_stage: begin // Delay Enable  
            state <= buffer_stage;
	    delay_enable <=1;
        end
	buffer_stage: begin // Buffer for update 
            state <= 0;
	    delay_enable <=0;
        end

        default: begin
	    delay_enable <=0;
            state <= state+1;
        end
    endcase
    end
end

KeyGeneration t0(rc,keyin,keyout);
subbytes t1(.data(data_in),.sb(sb));
shiftrow t2(.sb(sb_in),.sr(sr));
mixcolumn t3(.a(sr_in),.mcl(mcl));

assign rndout = (rc == 4'b1010) ? keyout^sr : keyout^mcl;
	

endmodule
