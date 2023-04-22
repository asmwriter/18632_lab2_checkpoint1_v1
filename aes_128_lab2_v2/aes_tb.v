`timescale 1ns / 1ps

`define CMD_ID 2'b00
`define CMD_ST 2'b01
`define CMD_SK 2'b10
`define CMD_SP 2'b11

module aes_tb(
    
);

// 100MHz clk
reg clk = 1'b0;
always #10 clk = !clk;
reg rst_ = 1'b1;

// reg [127:0] plain_text = 128'h 00041214120412000c00131108231919;
// reg [127:0] key = 128'h 2475a2b33475568831e2120013aa5487;
// reg [7:0] din;
// reg [1:0] cmd;
wire ok;
wire ready;
wire e128;
// wire [7:0] dout;

// aescipher u1(.clk(clk),.din(din),.cmd(cmd),.ok(ok),.ready(ready),.e128(e128),.rst_(rst_));
aescipher u1(.clk(clk), .ok(ok), .ready(ready), .e128(e128), .rst_(rst_));

integer i;
initial begin
	$dumpfile("aes_tb.vcd");
	$dumpvars(0,aes_tb);

    //Initialise i
    i = 0;
    #20
    rst_ = 1'b0;
    #200
    rst_ = 1'b1;
    #200;
    
    // cmd = `CMD_SP;
    // #10
    // for(i=0;i<16;i=i+1) begin
    //     din = plain_text[7:0];
    //     #10
    //     plain_text = plain_text >> 8;
    // end
    
    // cmd = `CMD_ID;
    // #20
    // cmd = `CMD_SK;
    // #10
//     for(i=0;i<16;i=i+1) begin
//         din = key[7:0];
//         #10
//         key = key >> 8;
//     end
    
//    cmd = `CMD_ID;
//    #20
//    cmd = `CMD_ST;
//    #20
//    cmd = `CMD_ID;
	
    #100000 $finish;
end

// always begin
// 	$display("rdata=%h", u1.rdata);
// 	$display("key_reg_t=%h", u1.key_reg_t);
// 	$display("input_reg_t=%h", u1.input_reg_t);
// end

always @(posedge clk) begin
	$display("rdata = %h", u1.rdata);
	$display("address = %h", u1.address);
    $display("e128 = %h", u1.e128);
end

// always begin
//     $display("e128 = %h", u1.e128);
// end

always @(posedge clk) begin
    if(ok == 1'b1 ) begin 
        i = i+1;
    end
    if(i == 20) begin
        #10 $finish;
    end
end

endmodule
