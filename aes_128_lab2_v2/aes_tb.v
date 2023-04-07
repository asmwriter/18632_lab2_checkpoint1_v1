`timescale 1ns / 1ns

`define CMD_ID 2'b00
`define CMD_ST 2'b01
`define CMD_SK 2'b10
`define CMD_SP 2'b11
`define ITER_NUM 500 //get from text file


module aes_tb(
    
);

// 100MHz clk
reg clk = 1'b0;
always #5 clk = !clk;


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

reg[31:0] vectornum, errors;   // bookkeeping variables 
reg[3:0]  testvectors[10000:0];// array of testvectors
reg[3:0]  testvectors1[10000:0];// array of testvectors
reg[3:0]  testvectors2[10000:0];// array of testvectors


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
// Will execute at the beginning once begin 
$readmemh("input_key.txt", testvectors); // Read vectors 
$readmemh("plain_text.txt", testvectors1); // Read vectors 
$readmemh("cipher_text.txt", testvectors2); // Read vectors 
vectornum= 0; errors = 0;// Initialize 
rst_ = 1; #27; rst_ = 0;// Apply rst_ wait 
end

// apply test vectors on rising edge of 
always @(posedge clk) begin 
#1;
if (~rst_) begin
if (ok) begin 
 {input_key, plain_text, cipher_text} = {testvectors[vectornum], testvectors1[vectornum], testvectors2[vectornum]}; 
end
end
end


// check results on falling edge of clk 
always @(posedge clk)  begin 
//always @(posedge ok)  begin 
if (ok) begin
if (~rst_)   begin            // skip during rst_ begin 
if (e128 !== 1) begin  
$display("Error: inputs = %b", {input_key, plain_text, cipher_text}); 
$display("  outputs vectornum=%b, e128= %b", vectornum, e128); 
errors = errors + 1; 
end	//if 
vectornum= vectornum+ 1; 
if (testvectors[vectornum] === `ITER_NUM) begin 
$display("%d tests completed with %d errors", vectornum, errors); 
$finish;// End simulation end end
end
end
end
end

endmodule
