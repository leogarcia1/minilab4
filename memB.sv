/** This module would skew the B matrix that would be fed into the 
 *			Systolic array
*/
module memB
  #(
    parameter BITS_AB=8,
    parameter DIM=8
<<<<<<< HEAD
	)
  (
		// Input 
    input clk,
		input rst_n,
		input en, 
    input signed [BITS_AB-1:0] Bin [DIM-1:0],
		// Output
    output signed [BITS_AB-1:0] Bout [DIM-1:0],
  );
		
	// Declare the gen variable
	genvar i;
		
	generate  
		for (i = 0; i < DIM; i = i + 1) begin // for B rows
			fifo FIFO_BLK#(.DEPTH(8+i),
							 .BITS(BITS_AB))
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
    
=======
    )
   (
    input clk,rst_n,en,
    input signed [BITS_AB-1:0] Bin [DIM-1:0],
    output signed [BITS_AB-1:0] Bout [DIM-1:0]
    );

endmodule
>>>>>>> 7db8b9be27e5118637b11963d8721dd773768bdd
