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
    output signed [BITS_AB-1:0] Aout [DIM-1:0] // In matrix first row [5, 4, 2, 1, ...], 5 is matrix 00 which is Ain[7] in verilog
);

// for the remaining rows apart from the 1st
reg signed [BITS_AB-1:0] Ain_intermediate [DIM-1:0][DIM-1:0];


genvar row;
generate
	for (row = DIM - 1; row >= 0; row++) begin
		// Prepare the values
		Ain_intermediate[row] =  (Arow === $clog2(DIM)'(row)) ? Ain : '{default: '0}}
	
		transpose_fifo #(
										.DEPTH(DIM + DIM - 1 - row)) 
										tf(
										.clk(clk),
										.rst_n(rst_n),
										.en(en),
										.WrEn(WrEn),
										.Ain(Ain_intermediate[row]),
										.Aout(Aout[row]));				
		end
	end
endgenerate

endmodule