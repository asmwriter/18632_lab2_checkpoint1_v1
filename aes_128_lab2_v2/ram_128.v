//.address(address),.clock(clk_div),.data(wdata),.wren(wren),.q(rdata)
/*
module ram(address, clock, data, wren, q, rst);

    input [31:0] address;
	input [127:0] data, q;
    input wren, clock, rst;

    reg [127:0] mem_128 [31:0];

    assign q = mem_128[address];

    

    always @(posedge clock) begin
        if(rst == 1'b0) begin
            // for(int i=3;i<32;i++) begin
            //     mem_128[i] <= 128'h00000000000000000000000000000000;
            // end
            mem_128[0] <= 128'h80000000000000000000000000000000;
            // mem_128[1] <= 128'h0000000000000000000000000000000; 
            // mem_128[2] <= 128'h3ad78e726c1ec02b7ebfe92b23d9ec34;
        end
        else begin
            if(wren) begin
                mem_128[address] <= data;
            end
        end
    end
endmodule
*/

module ram (address, clock, data, wren, q, rst);

parameter D_WIDTH = 128;
parameter AD_WIDTH = 32;
parameter DEPTH = 32;

input [AD_WIDTH-1:0] address;
input [D_WIDTH-1:0] data;
input wren, clock, rst;
output [D_WIDTH-1:0] q;

reg [D_WIDTH-1:0] mem [DEPTH];

assign q = (wren == 1'b0) ? mem[address] : {D_WIDTH{1'bz}};

always @(posedge clock) begin
    if(rst == 1'b0) begin
            for(int i=3;i<32;i++) begin
                mem[i] <= 128'h00000000000000000000000000000000;
            end
            mem[0] <= 128'h80000000000000000000000000000000;
            mem[1] <= 128'h0000000000000000000000000000000; 
            mem[2] <= 128'h3ad78e726c1ec02b7ebfe92b23d9ec34;
    end
    else begin
        if (wren) begin
            mem[address] <= data;
        end
    end
end
endmodule