class memA_tc #(parameter BITS_AB=8,
                parameter DIM=8);

	typedef reg signed [BITS_AB-1:0] defaultMatrix [DIM-1:0][DIM-1:0];
	defaultMatrix A; // Holds the A matrix which would be used in the multiply operation
	reg signed [BITS_AB-1:0] A_skewed [3*DIM-2-1:0][DIM-1:0]; // Skewed matrix A

	int cycle;

	function new();
			for (int i=0; i<DIM; i++)begin
					for (int j=0; j<DIM; j++)begin
							A[i][j] = 0;
					end
			end
			
			// Zero out skewed array
			for(int i=0; i<3*DIM-2; i++) begin // TODO
				for(int j=0; j<DIM; j++) begin
						A_skewed[i][j] = {BITS_AB{1'b0}};
				end
			end
			
			//initialize cycle number
			cycle = 0; 
	endfunction: new

	function defaultMatrix new_matrix();
			// Randomize A and return a matrix of random values
			for (int row=0; row<DIM; ++row)begin
					for (int col=0; col<DIM; ++col)begin
							A[row][col] =  BITS_AB'($urandom());
					end
			end
			return A;
	endfunction: new_matrix

	function int next_cycle();
			cycle = cycle + 1;
			return cycle;
	endfunction: next_cycle

	// Initializes a 2D skewed matrix from skewed matrix 
	function void initialize_skewed_A();
		for(int i= DIM - 1; i>=0; i--) begin
			for(int j = DIM - 1 - i; j < (2*DIM)-1-i; j++)
				A_skewed[j][i] = A[i][(2*DIM)-2-i-j];
		end
	endfunction: initialize_skewed_A

	// Compares 
	function int compareMatRow(reg signed [BITS_AB-1:0] memA_test [3*DIM-2-1:0][DIM-1:0]);
		int numErrors = 0;
		
		for(int i=0; i<3*DIM-2; i++)begin
			for(int j=DIM - 1; j>=0; j--) begin
				if(A_skewed[i][j] !== memA_test[i][j]) begin
					numErrors++;
					$display("Error: Expected %x not %x", A_skewed[i][j], memA_test[i][j]);
				end
			end
		end
			
		return numErrors;
	endfunction: compareMatRow

	function void dump(reg signed [BITS_AB-1:0] memA_test[3*DIM-2-1:0][DIM-1:0]);
			// display memA for debugging purposes
			$display("memA:\n");
			
				for(int i = 0; i < 3*DIM-2; i++)begin
					for(int j=DIM - 1; j>=0; j--) begin
							$write("%H ",memA_test[i][j]);
					end
					$display("");
			end
	endfunction: dump
endclass