/*
* memA module, which is a memory that stores the data as input to tpumac.
* Takes input of 8 bit * 8 elements (which is a row)
* outputs a 8 bit * 8 elements (which is a column)
*/
module memA
#(
    parameter BITS_AB=8,
    parameter DIM=8
)
(
    input clk,rst_n,en,WrEn,
    input signed [BITS_AB-1:0] Ain [DIM-1:0],
    input [$clog2(DIM)-1:0] Arow,
    output signed [BITS_AB-1:0] Aout [DIM-1:0]
);


genvar row;
generate
	for (row=0; row<DIM; row++) begin
		if(row == 0)
			transpose_fifo tf(.clk(clk),.rst_n(rst_n),.en(en),.WrEn(WrEn),.Ain(Ain),.Aout(Aout[0]));

		else
			transpose_fifo #(DEPTH = DIM + row) tf(.clk(clk),.rst_n(rst_n),.en(en),.WrEn(WrEn),.Ain({row{b'0},Ain}),.Aout(Aout[row]));
	end
endgenerate

endmodule