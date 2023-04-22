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
    // input [127:0] input_key,
    // input [127:0] plain_text,	
    // input [127:0] cipher_text,	
    output ready,
	output  e128,
	output clk_out,
    output reg ok
);

	wire clk_div;
   
	 clock_divider clk_div_ins0(clk, clk_div);
	
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

    wire delay_enable;
   
		assign clk_out = clk_div;
	
    //Only for synthesis (place and route)
//	wire [127:0] input_key = 128'h0000000000000000000000000000000;
//	wire [127:0] plain_text = 128'h80000000000000000000000000000000;
//	wire [127:0] cipher_text = 128'h3ad78e726c1ec02b7ebfe92b23d9ec34;

	
	//wire [127:0] input_key;
	//wire [127:0] plain_text;
	reg [127:0] cipher_text;
 
	reg [127:0] key_reg_t;
	reg [127:0] input_reg_t;

	
	//RAM instantiation 
	reg [31:0] addr;
	wire [31:0] address;
	wire [127:0] rdata;
	reg [127:0] wdata;
	reg wren;

	//assign address = (state_cnt == `S_SP)? 32'd0 : (state_cnt == `S_SK)? 32'd1 : 32'd2; 

	//assign input_key = (address == 32'h1)? rdata : input_key;
	//assign plain_text = (address == 32'h0)? rdata : plain_text;
	//assign cipher_text = (address == 32'h2)? rdata : cipher_text;
	
	ram ram_large_ins0(.address(address),.clock(clk_div),
                    .data(wdata),.wren(wren),.q(rdata),.rst(rst_));
	
	assign address = addr;
	
    
    //rounds r(.clk(),.rc(round_cnt),.data(state_reg),.keyin(key_reg),.keyout(round_key_out),.rndout(round_state_out));
    
    rounds r(.clk(clk_div),.rst_(rst_),.rc(round_cnt),.data(state_reg),.keyin(key_reg),.keyout(round_key_out),.rndout(round_state_out),.delay_enable_t(delay_enable));
   
  //  assign dout = final_out_reg[7:0];
    reg [1:0] state_cnt; 
    assign ready = (state_cnt == `S_ID);
	 
	 //wire[127:0] expected128 = 128'h_69c4e0d86a7b0430d8cdb78070b4c55a;
	 wire[127:0] expected128;
	 //wire[127:0] expected128 = 128'h_69c4e0d86a7b0430d8cdb78070b4c55b;	//incorrect
    
	 
	 reg [10:0] count;
    assign e128 = ((!complt_) && (final_out_reg == cipher_text)) ? 1'b1: 1'b0;
    //control FSM
    always @ (posedge clk_div or negedge rst_) begin
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
            cipher_text <= 128'b0;
	        // e128 <= 1'b0;	
			cmd <= `CMD_SP;
			count <= 0;
			addr <= 32'd0;
			wren <= 1'b0;
			key_reg_t <= 32'b0; 
			input_reg_t <= 32'b0;
        end
        else begin
            case(state_cnt)
                `S_ID: begin
                    if(ok) begin
                                cmd <= `CMD_SP;
                                ok <= 1'b0;
                                count <= 0; 
										  wren <= 1'b0;

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
							//	addr <= 32'b0;
                        case(cmd)
                            `CMD_ST: begin state_cnt <= `S_ST; addr <= 32'd2; wren <= 1'b0; end//last round 
                            `CMD_SK: begin state_cnt <= `S_SK; addr <= 32'd1; wren <= 1'b0; end //3rd  
                            `CMD_SP: begin state_cnt <= `S_SP; addr <= 32'd0; wren <= 1'b0; end//2nd 
                            //defualt : state_reg <= `S_ID; //1st or intermediate
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
									// wren <= 1'b0;	
                            state_reg <= pre_round;
                            round_cnt <= round_cnt + 4'b1;
                        end
                        else if(round_cnt < 4'b1010 && delay_enable) begin
                            state_reg <= round_state_out;
                            key_reg <= round_key_out;
                            round_cnt <= round_cnt + 4'b1;
                        end
                        else if(round_cnt == 4'b1010 && delay_enable) begin
                            final_out_reg <= round_state_out;
                            addr <= 4'd3;
                            wren <= 1'b1;
                            wdata <= input_reg_t;
                            cipher_text <= rdata;
                            round_cnt <= 4'b0;
                            complt_ <= 1'b0;
                            ok <= 1'b1;
                        end
                    end            
                end
                `S_SK: begin
						//	key_reg <= input_key; 
						//	addr <= 32'b2;
							key_reg <= rdata;
							key_reg_t <= rdata; 
			
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
						//	state_reg <= plain_text;
							state_reg <= rdata;
							input_reg_t <= rdata;
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


module clock_divider(clock_in, clock_out);
	input clock_in;
	output reg clock_out; // output clock after dividing the input clock by divisor
	reg[15:0] counter=16'd0;
	parameter DIVISOR = 16'd50000;
	// The frequency of the output clk_out
	//  = The frequency of the input clk_in divided by DIVISOR
	// For example: Fclk_in = 50Mhz, if you want to get 1Hz signal to blink LEDs
	// You will modify the DIVISOR parameter value to 28'd50.000.000
	// Then the frequency of the output clk_out = 50Mhz/50.000.000 = 1Hz
	always @(posedge clock_in)
		begin
		 counter <= counter + 16'd1;
		 if(counter>=(DIVISOR-1))
		  counter <= 16'd0;
		 clock_out <= (counter<DIVISOR/2)?1'b1:1'b0;
		end
endmodule
