/**
* This module would test the mem_B block
*/
`include "memB_tc.svh"
module memB_tb();
	localparam BITS_AB=8;
	localparam DIM=8;
	// Change when more rows are added in
	localparam numOfExpectedRowOutput = DIM; // keeps track of expected number of outputs from memB
	localparam numMatRows = 1; // number of rows in matrix
	reg clk;
	reg rst_n;
	reg en;
	reg signed [BITS_AB-1:0] Bin [DIM-1:0];
	reg signed [BITS_AB-1:0] Bout [DIM-1:0];
	int vecIdx; // the entry to write to in vector
	int currMatRow;
	int errors; // keeps track of number of errors in the tb
	
	// DUT instance (memB)
	memB #(
    .BITS_AB(BITS_AB),
    .DIM(DIM)
		) MEMB_INST0
		(
			// Input 
			.clk(clk),
			.rst_n(rst_n),
			.en(en), 
			.Bin(Bin),
			// Output
			.Bout(Bout)
		);
	
	// contains functions
	memB_tc #(.BITS_AB(BITS_AB),
			.DIM(DIM),
			.numOfExpectedRowOutput(numOfExpectedRowOutput)
			) funcMod;
	

	initial begin
		clk = 1'b0; // initialize clock 
		rst_n = 1'b1;
		en = 1'b0;
		vecIdx = 0;
		// Initialize the Bin vector array
		for(int i = 0; i < DIM; i = i + 1)
			Bin[i] = {BITS_AB{1'b0}};
		errors = 0;
		currMatRow = 0;
		//memB_tcINST funcMod;
		
		// Initialize class with the functions instance
		funcMod = new();

		// Reset
		@(negedge clk) rst_n = 1'b0;
		
		// Wait 
		repeat(2) @(negedge clk);
		
		// Deassert Reset
		@(negedge clk) rst_n = 1'b1;
		
		// Initilize B_in 
		@(negedge clk) begin
			for(int k = 0; k < numMatRows; k = k + 1) begin
			
				for(int i = 0; i < DIM; i = i + 1) begin
					vecIdx = funcMod.get_vector_index();
					Bin[vecIdx] = funcMod.get_random_B_entry();
					funcMod.next_vector_index(); // advances to next position to be initialized
				end
				
				// Initialize cascaded array
				funcMod.initialize_skewed_B(numMatRows); // Update value for adding more rows in B matrix (used in actual multiplication)
				
				// enable the memB to constantly shift in incoming rows
				en = 1'b1;
				
				// Zero out the flip flow input 
				@(negedge clk) begin
					for(int i = 0; i < DIM; i = i + 1) begin
						Bin[i] = {BITS_AB{1'b0}};
					end
				end
				
				// Wait for memB entries to settle in fifo
				if(k === 0)
					repeat(6) @(negedge clk); 
				else
					@(negedge clk); 
				
			end
			
		end
		
		// enable the memB to constantly produce rows
		en = 1'b1;
		
		// check all rows that are expected from the memB module
		for(int i = 0; i < numOfExpectedRowOutput; i = i + 1) begin
			@(negedge clk) begin
				// Compare Bout with actual values
				currMatRow = funcMod.get_matrix_row();
				errors += funcMod.compareMatRow(currMatRow, Bout);
				funcMod.next_matrix_row(); // increment row
			end
		end
		
		// disable memB
		en = 1'b0;
		
		if(errors === 0) 
			$display("Mission Successful!!! All tests passed");
		else
			$display("Mission Failed! Check module and modify");

		funcMod.dumpMatrix();
		
		// End Simulation
		$stop;
	
	end
	
	
	// Create clock
	always @(clk) begin
		clk <= #5 ~clk;
	end

endmodule

