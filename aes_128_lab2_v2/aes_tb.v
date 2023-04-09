`timescale 1ns / 1ps

`define CMD_ID 2'b00
`define CMD_ST 2'b01
`define CMD_SK 2'b10
`define CMD_SP 2'b11
`define ITER_NUM 2 //get from text file


module aes_tb(
    
);

logic clk;
reg [127:0] plain_text;
reg [127:0] input_key;
reg [127:0] cipher_text;

//reg [127:0] plain_text = 128'h 00041214120412000c00131108231919;
//reg [127:0] input_key = 128'h 2475a2b33475568831e2120013aa5487;
//reg [127:0] cipher_text = 128'h_69c4e0d86a7b0430d8cdb78070b4c55a;
reg rst_ = 1'b1;
wire ok;
wire ready;
wire [7:0] dout;
reg e128;


reg first_round;
reg[31:0] vectornum, errors;   // bookkeeping variables 
reg[127:0]  testvectors[`ITER_NUM-1:0];// array of testvectors
reg[127:0]  testvectors1[`ITER_NUM-1:0];// array of testvectors
reg[127:0]  testvectors2[`ITER_NUM-1:0];// array of testvectors


//aescipher u1(.clk(clk),.din(din),.cmd(cmd),.ok(ok),.ready(ready),.dout(dout),.rst_(rst_));
aescipher u1(.clk(clk),.ok(ok),.ready(ready),.dout(dout),.rst_(rst_), .e128(e128), .input_key(input_key), .plain_text(plain_text), .cipher_text(cipher_text));
integer i;
/*
initial begin
    #20
    rst_ = 1'b0;
    #20
    rst_ = 1'b1;
    #1000;

$display("OUTPUT: e128:%d\n", e128);

$finish;	
end
*/    
   /* 
    cmd = `CMD_SP;
    #10
    for(i=0;i<16;i=i+1) begin
        din = plain_text[7:0];
        #10
        plain_text = plain_text >> 8;
    end
    
    cmd = `CMD_ID;
    #20
    cmd = `CMD_SK;
    #10
    for(i=0;i<16;i=i+1) begin
        din = key[7:0];
        #10
        key = key >> 8;
    end
    
   cmd = `CMD_ID;
   #20
   cmd = `CMD_ST;
   #20
   cmd = `CMD_ID;
    */

initial begin
	clk = 1'b1;
	forever #10ns clk = ~clk;
end

initial begin            
// Will execute at the beginning once begin 	
	$readmemh("input_key.txt", testvectors); // Read vectors 
	$readmemh("plain_text.txt", testvectors1); // Read vectors 
	$readmemh("cipher_text.txt", testvectors2); // Read vectors 
	$display("input: plaintext[vectornum]=%x",testvectors1[0]);
	$display("input: key[vectornum]=%x",testvectors[0]);
	$display("output ciphertext[vectornum]=%x",testvectors2[0]);
	// Initialize 
	vectornum= 0; errors = 0;
	//for inputting plaintext,keys for first round
	first_round = 1'b1;
	// Apply rst_ 
	rst_ = 0; #100; rst_ = 1;


// #10000
// $finish;
end



// apply test vectors on rising edge of 
always @(posedge clk) begin 
	#1;
	if (rst_) begin
		if ((ok || first_round) && vectornum < `ITER_NUM) begin 
	 		{input_key, plain_text, cipher_text} <= {testvectors[vectornum], testvectors1[vectornum], testvectors2[vectornum]}; 
			first_round <= 1'b0;
			
		end
	end
	// $display("state=%x", u1.state_cnt);
	// $display("state_reg=%x", u1.state_reg);
	// $display("key_reg=%x", u1.key_reg);
	// $display("vectornum=%x, e128=%x, ok=%x\n",vectornum,e128,ok);
	// $display("input: plaintext[vectornum]=%x",testvectors1[vectornum]);
	// $display("input: key[vectornum]=%x",testvectors[vectornum]);
	// $display("output ciphertext[vectornum]=%x",cipher_text);
end


// check results on falling edge of clk 
always @(posedge clk)  begin 
	if(u1.state_cnt == `S_SP) begin
		$display("state_reg : %x", u1.state_reg);
	end
	if(u1.state_cnt == `S_SK) begin
		$display("key_reg : %x", u1.key_reg);
	end
	if(u1.state_cnt == `S_ST) begin
		if(u1.round_cnt == 0) begin
			$display("round count: %x", u1.round_cnt);
			$display("data in : %x", u1.state_reg);
			$display("data out %x", u1.pre_round);
			$display("key in: %x", u1.key_reg);

		end
		if(u1.complt_) begin
			$display("round count: %x", u1.round_cnt);
			$display("data in : %x", u1.state_reg);
			$display("data out: %x", u1.round_state_out);
			$display("key in: %x", u1.key_reg);
		end
	end
	if (ok) begin
		if (rst_)   begin            // skip during rst_ begin 
			if (e128 !== 1 && u1.state_cnt == `S_ID) begin 
				// $display("Error: inputs = %b", {input_key, plain_text, cipher_text}); 
				$display("Error for vectornum: %d", vectornum);
				$display(" Expected cipher_text=%x", cipher_text); 
				
				$display(" Output cipher_text=%x, e128= %b", u1.final_out_reg, e128);  
				errors = errors + 1; 
			end	//if
			else begin
				$display("Matched for vectornum: %d", vectornum);
			end
			vectornum <= vectornum + 1;
			if (vectornum == `ITER_NUM) begin 
				$display("%d tests completed with %d errors", vectornum, errors); 
				#1000
				$finish;
			end
		end
	end
end

endmodule
