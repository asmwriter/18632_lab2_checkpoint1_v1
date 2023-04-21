`timescale 1ns / 1ps
`define NUM 4'd8

// Key Generation starts at the first cycle of every round 
// Last Stage is buffer. 
// Last but one is for delay enable. Others can be used with varied 
//`define SB_EN 8'd10
//`define SR_EN 8'd16
//`define MC_EN 5'd24
// Each thing will happen in the next cycle. 

module rounds(clk,rst_,rc,data,keyin,keyout,rndout,delay_enable_t);
input clk;
input rst_;
input [3:0]rc;
input [127:0]data;
input [127:0]keyin;
output [127:0]keyout;
output [127:0]rndout;
output delay_enable_t;

wire [127:0] sb,sr,mcl;

// For Delay 
reg [`NUM-1:0] state = 0;
reg [127:0] sb_in,sr_in,data_in;
reg delay_enable;
wire [127:0] rndout;
reg [`NUM-1:0] sb_en = 'd6;
reg [`NUM-1:0] sr_en = 'd12;
wire [`NUM-1:0] round_delay;
reg [`NUM-1:0] mc_en = 'd18;
assign round_delay = 10*rc;
wire [`NUM-1:0] con;
assign con = mc_en + 2 + round_delay;
wire [`NUM-1:0] delay_stage;
assign delay_stage = con-1;
wire [`NUM-1:0] buffer_stage;
assign buffer_stage = con;

assign delay_enable_t = delay_enable;

always @ (posedge clk) begin
    if (!rst_) begin 
    	state <= 0 ;
    end
    else begin
    case (state)
        sb_en: begin
            state <= state + 1;
	    data_in <= data;
        end
        sr_en: begin
            state <= state + 1;
            sb_in <= sb;
        end
        mc_en: begin
            state <= state +1 ;
            sr_in <= sr;
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
