`timescale 1ns / 1ps

module rounds(clk,rc,data,keyin,keyout,rndout,delay_enable);
input clk;
input [3:0]rc;
input [127:0]data;
input [127:0]keyin;
output [127:0]keyout;
output [127:0]rndout;
output delay_enable;

wire [127:0] sb,sr,mcl;

// For Delay 
reg[2:0] state;
reg[127:0] sb_in,sr_in,data_in;
reg delay_enable,out_enable;
reg [2:0] delay_count = 3'b000;
reg [127:0] rndout_test;
reg[127:0] rndout;

always @(posedge clk) begin
    if (delay_count % 6 == 0) begin
	delay_count <=1;
    end
    else begin
    delay_count <= delay_count +1;
    end
    end

always @ (posedge clk) begin
    case (state)
        3'b000: begin // Key Generation
            state <= 3'b001;
	    data_in <= data;
        end
        3'b001: begin // Subbytes
            state <= 3'b010;
            sb_in <= sb;
        end
        3'b010: begin // ShiftRows
            state <= 3'b011;
            sr_in <= sr;
        end
        3'b011: begin // Mix Columns
            state <= 3'b100;
	    out_enable <= 1;
        end   
	3'b100: begin // rndout 
            state <= 3'b101;
	    out_enable <=0;
	    delay_enable <=1;
        end
	3'b101: begin // Buffer for update 
            state <= 3'b000;
	    delay_enable <=0;
        end
        default:
            state <= 3'b000;
    endcase
end


KeyGeneration t0(rc,keyin,keyout);
subbytes t1(.data(data_in),.sb(sb));
shiftrow t2(.sb(sb_in),.sr(sr));
mixcolumn t3(.a(sr_in),.mcl(mcl));

always @(posedge clk) begin
	if(out_enable) begin
		rndout <= (rc == 4'b1010) ? keyout^sr : keyout^mcl ;
	end
end

/*
KeyGeneration t0(rc,keyin,keyout);
subbytes t1(data,sb);
shiftrow t2(sb,sr);
mixcolumn t3(sr,mcl);

assign rndout = (rc == 4'b1010) ? keyout^sr : keyout^mcl ;
*/	

endmodule
