/** This module would skew the B matrix that would be fed into the 
 *			Systolic array
*/
module memB
  #(
    parameter BITS_AB=8,
    parameter DIM=8
	)
  (
		// Input 
    input clk,
		input rst_n,
		input en, 
    input signed [BITS_AB-1:0] Bin [DIM-1:0],
		// Output
    output signed [BITS_AB-1:0] Bout [DIM-1:0]
  );
		
	// Declare the gen variable
	genvar i;
		
	generate  
		for (i = 0; i < DIM; i = i + 1) begin // for B rows
			fifo #(.DEPTH(8+i),
						.BITS(BITS_AB)
						) FIFO_BLK 
						(
						.clk(clk),
						.rst_n(rst_n),
						.en(en),
						.d(Bin), // NOTE: Assuming [5,2,1,3,...] => 5 is index 0 of matrix
						.q(Bout)
						);
		end
		
	
	endgenerate 
endmodule
