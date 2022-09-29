/** 
* This module would contain the functions that would be used
* 	in the memB_tb module (testbench)
*/

class memB_tc #(parameter BITS_AB=8,
								parameter DIM=8,
								parameter numOfExpectedRowOutput = DIM
							);
	reg signed [BITS_AB-1:0] B_matrix [DIM-1:0][DIM-1:0]; // each row is the entry expected by the memB module
	int BMatRow; // the current B row in the B matrix
	reg signed [BITS_AB-1:0] BVec [DIM-1:0]; // B vector that would be skewed
	
	int BVecIdx; // the vector index of the vector that is currently being filled
	int numRandGenerated; // number of random values generated
	
	
	// This function would initialize the variables that 
	// 	would be used in the testbench
	function new();
		numRandGenerated = 0;
		BVecIdx = 0;
		BMatRow = 0;
		
		// Initialize B Matrix 
		for(int i = 0; i < numOfExpectedRowOutput; i = i + 1) begin
			for(int j = 0; j < DIM; j = j + 1) begin
				B_matrix[i][j] = 'b0;
			end
		end
		
		// Initialize row vector 
		for(int i = 0; i < DIM; i = i + 1) begin
				BVec[i] = 'b0;
		end
	
	endfunction: new
	
	// Returns the vector index whose position is being 
	//		filled in the B vector
	function int get_vector_index();
		return BVecIdx;
  endfunction: get_vector_index		
	
	// Increments the vector index whose position would be 
	// 	written to next
	function void next_vector_index();
		BVecIdx = BVecIdx + 1;
  endfunction: next_vector_index		
	
	// Initialize current position in vector
	function void initialize_vector_index_tb(reg signed [BITS_AB-1:0] randomGenerated);
		// Initilize index in vector
		BVec[BVecIdx] = randomGenerated;
  endfunction: initialize_vector_index_tb
	
	// Returns random B entry (calls multiple times gto initialize whole vector)
	function reg signed [BITS_AB-1:0] get_random_B_entry();
		reg signed [BITS_AB-1:0] randomGenerated; // random number generated 
		
		// Initialize random number
		randomGenerated = BITS_AB'($random);
		
		// Increments number of random numbers generated
		numRandGenerated += 1;
		
		// Initializes vector position at current index
		initialize_vector_index_tb(randomGenerated);
		
		return randomGenerated;
	endfunction: get_random_B_entry
							
	
	// Initializes a 2D matrix from a 1D array vector
	// rowVecNum => the row in the original B matrix that needs to be skewed
	function void initialize_skewed_B(int rowVecNum); // default should be 0 to initialize matrix to be similar to identity matrix
		// Ensure whole vector has first been initialized
		if(numRandGenerated % DIM == 0) begin
			for(int i = 0; i < DIM; i = i + 1) begin
				B_matrix[rowVecNum - 1 + DIM - 1 - i][DIM - 1 - i] = BVec[DIM - 1 - i];
			end
		end
  endfunction: initialize_skewed_B
	
	// compRow is the row to be compared
	// BVecComp is the vector to be compared
	function int compareMatRow(int compRow, reg signed [BITS_AB-1:0]BVecComp[DIM-1:0]);
		int numErrors = 0;
		for(int i = 0; i < DIM; i = i + 1) begin
				if(B_matrix[numOfExpectedRowOutput - compRow - 1][i] !== BVecComp[i]) begin
					numErrors++;
					$display("Error: Expected %x not %x", B_matrix[numOfExpectedRowOutput - compRow - 1][i], BVecComp[i]);
				end
		end
		
		// ss("There are some errors in the %d row", compRow);
			
		return numErrors;
	endfunction: compareMatRow
	
	// Get the current row of the B matrix to be checked
	function int get_matrix_row();
		return BMatRow;
  endfunction: get_matrix_row	

	// Update the next row of the B matrix
	function void next_matrix_row();
		BMatRow = BMatRow + 1;
  endfunction: next_matrix_row	
	
	// Resets the current row of the B matrix to 0 (the first)
	function int reset_matrix_row();
		BMatRow = 0;
  endfunction: reset_matrix_row	

	// Writes out all the rows in the B matrix
	function void dumpMatrix(); 
		for(int j = 0; j < numOfExpectedRowOutput; j = j + 1) begin
			for(int i = 0; i < DIM; i = i + 1) begin
				$write("%x ", B_matrix[numOfExpectedRowOutput - 1 - j][DIM - 1 - i]);
			end
			$display(""); // newline
		end
	endfunction: dumpMatrix
					
endclass:memB_tc
