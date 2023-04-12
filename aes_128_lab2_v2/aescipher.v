`timescale 1ns / 1ps

`define S_ID 2'b00
`define S_SP 2'b01
`define S_SK 2'b10
`define S_ST 2'b11

//state definations

`define CMD_ID 2'b00
`define CMD_ST 2'b01
`define CMD_SK 2'b10
`define CMD_SP 2'b11

//cmd defination

module aescipher(
    input clk,
    input rst_,
    // input [7:0] din,
    //input [1:0] cmd,
   // input [127:0] input_key,
   // input [127:0] plain_text,	
   // input [127:0] cipher_text,	
   // output [7:0] dout,
    output ready,
	output  e128,
    output reg ok
);

    // //Only for synthesis (place and route)
	 wire input_key = 128'h0000000000000000000000000000000;
	 wire plain_text = 128'h80000000000000000000000000000000;
	 wire cipher_text = 128'h3ad78e726c1ec02b7ebfe92b23d9ec34;


//anu 	reg [31:0] addr;
//anu 	wire [31:0] address;
//anu 	wire [127:0] rdata;

    wire [127:0] pre_round;
    
    reg plain_ok_;
    reg key_ok_;
    reg complt_;
    reg [3:0] key_count; 
    reg [3:0] plain_count;
    reg [127:0] final_out_reg;
    //assign ok = !complt_;
    reg [1:0] cmd;
    reg [127:0] key_reg;
    reg [127:0] state_reg;
    reg [3:0] round_cnt;
    reg [3:0] output_cnt;
    
    wire [127:0] round_key_out;
    wire [127:0] round_state_out;
    assign pre_round = state_reg ^ key_reg;
   
    rounds r(.clk(),.rc(round_cnt),.data(state_reg),.keyin(key_reg),.keyout(round_key_out),.rndout(round_state_out));
    
   
    assign dout = final_out_reg[7:0];
    reg [1:0] state_cnt; 
    assign ready = (state_cnt == `S_ID);
	 
	 //wire[127:0] expected128 = 128'h_69c4e0d86a7b0430d8cdb78070b4c55a;
	 wire[127:0] expected128;
	 //wire[127:0] expected128 = 128'h_69c4e0d86a7b0430d8cdb78070b4c55b;	//incorrect
    
	 reg [10:0] count;
    assign e128 = (final_out_reg == cipher_text) ? 1'b1: 1'b0;
    //control FSM
    always @ (posedge clk or negedge rst_) begin
        if(!rst_) begin
            round_cnt <= 4'b0;
            state_cnt <= `S_ID;
            plain_ok_ <= 1'b1;
            key_ok_ <= 1'b1;
            complt_ <= 1'b1;
            key_count <= 4'b0;
            plain_count <= 4'b0;
            ok <= 1'b0;
            output_cnt <= 4'b0;
            final_out_reg <= 128'b0;
	        // e128 <= 1'b0;	
			cmd <= `CMD_SP;
			count <= 0;
        end
        else begin
            case(state_cnt)
                `S_ID: begin
                    if(ok) begin
                                cmd <= `CMD_SP;
                                ok <= 1'b0;
                                count <= 0; 

								/*
                                if(output_cnt == 4'd15) begin
                                    ok <= 1'b0;
                                    output_cnt <= 4'b0;
                                end
                                else begin
                                    output_cnt <= output_cnt + 4'b1;
                                    final_out_reg <= final_out_reg >> 8;
                                end
								*/
                    end
                    else begin
                        case(cmd)
                            `CMD_ST: state_cnt <= `S_ST;
                            `CMD_SK: state_cnt <= `S_SK;
                            `CMD_SP: state_cnt <= `S_SP;
                            //defualt : state_reg <= `S_ID;
                        endcase
                    end 
                end
                `S_ST: begin
                    if(!complt_) begin 
                        state_cnt <= `S_ID;
                        complt_ <= 1'b1;
                    end
                    else begin
                        if(round_cnt == 4'b0) begin
                            state_reg <= pre_round;
                            round_cnt <= round_cnt + 4'b1;
                        end
                        else if(round_cnt < 4'b1010) begin
                            state_reg <= round_state_out;
                            key_reg <= round_key_out;
                            round_cnt <= round_cnt + 4'b1;
                        end
                        else if(round_cnt == 4'b1010) begin
                            final_out_reg <= round_state_out;
                            round_cnt <= 4'b0;
                            complt_ <= 1'b0;
                            ok <= 1'b1;
                        end
                    end            
                end
                `S_SK: begin
							//key_reg <= 128'h 2475a2b33475568831e2120013aa5487;
							//key_reg <= 128'h_000102030405060708090a0b0c0d0e0f;
							key_reg <= input_key;
							state_cnt <= `S_ID;
							cmd <= `CMD_ST;
							/*
                    if(!key_ok_) state_cnt <=`S_ID;
                    else begin
                        if(key_count == 4'd15) begin
                            key_ok_ <= 1'b0;
                        end
                        key_count <= key_count + 4'b1;
                        key_reg <= {din,key_reg[127:8]};
                    end
						  */
						  
                end
                `S_SP: begin
							//state_reg <= 128'h 00041214120412000c00131108231919;
							//state_reg <= 128'h_00112233445566778899aabbccddeeff;
							state_reg <= plain_text;
							state_cnt <= `S_ID;
							cmd <= `CMD_SK;
						  /*
                    if(!plain_ok_) state_cnt <= `S_ID;
                    else begin
                        if(plain_count == 4'd15) begin
                            plain_ok_ <= 1'b0;
                        end
                        plain_count <= plain_count + 4'b1;
                        state_reg <= {din,state_reg[127:8]};
                    end
						  */
                end
            endcase
        end
    end
    
endmodule
