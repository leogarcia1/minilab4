// memA test bench

`include "memA_tc.svh"

module memA_tb();

    localparam BITS_AB=8;
    localparam DIM=8;
    localparam ROWBITS=$clog2(DIM);
    localparam TESTS=1;

    // Clock
    logic clk;
    logic rst_n;
    logic en;
    logic WrEn;
    // Signal that selects which row the tb will write to
    logic [ROWBITS-1:0] Arow;
    // Raw input values which will be pumped into the memA module
    logic signed [BITS_AB-1:0] A [DIM-1:0][DIM-1:0];
    // Input rows which will be pumped into the memA module
    logic signed [BITS_AB-1:0] Ain [DIM-1:0];
    // A matrix that stores the giant square shape data which contains a rhombus shaped A
    logic signed [BITS_AB-1:0] Aout [3*DIM-2-1:0][DIM-1:0];
    // Temporary value that stores the value coming out of memA
    logic signed [BITS_AB-1:0] Aout_tmp [DIM-1:0];

    // Generate clock
    always #5 clk = ~clk;

    // Keep track of how many errors and which cycle is the tb in
    integer errors, mycycle;

    // Instantiate the device under test
		memA #(.BITS_AB(BITS_AB), 
					.DIM(DIM)) 
					iDUT(
						.clk(clk), 
						.rst_n(rst_n), 
						.en(en), 
						.WrEn(WrEn), 
						.Ain(Ain), 
						.Arow(Arow), 
						.Aout(Aout_tmp));
						
    memA_tc #(.BITS_AB(BITS_AB), .DIM(DIM)) matc;

    initial begin
        // Instantiate the testing case
        matc = new();
        clk = 1'b0;
        rst_n = 1'b1;
        mycycle = 0;
        // Hold the memA from operating until later stage after all values are present in memA
        en = 1'b0;
        WrEn = 1'b0;
        errors = 0;
				Arow = {ROWBITS{1'b0}};
				// Initialize DUT input
				for(int i = 0; i < DIM; i++)
					Ain[i] = {BITS_AB{1'b0}};
        
        //----------- INITIALIZE BLOCK: Initialize values in different matrices to 0 ------------
        // reset and check Cout
        repeat(2) @(negedge clk);
					rst_n = 1'b0; // active low reset
					
        @(negedge clk);
					rst_n = 1'b1; // reset finished
					
        @(negedge clk) begin
            // Initialize values in different matrices to 0
						for(int i=0;i<DIM;++i) begin
							for(int j=0;j<DIM;++j) begin
									A[i][j] = {BITS_AB{1'b0}};  // reset storing matrix (2D matrix)
							end
            end
						
						for(int i=0; i<3*DIM-2; i++) begin // TODO
							for(int j=0; j<DIM; j++) begin
									Aout[i][j] = {BITS_AB{1'b0}};
							end
            end
        end
        //----------- END INITIALIZE BLOCK: Initialize values in different matrices to 0 ------------
        //----------- TESTING BLOCK: test memA behavior MULTIPLE TIMES using different random value matrices ------------
        for(int test=0; test<TESTS; test++)begin
					A = matc.new_matrix();  // Generate new random values to test memA
					
					// Initialize the skewed array
					matc.initialize_skewed_A();

					// Start writing values into the memA module
					for(int i=0; i<DIM; ++i)begin
							@(negedge clk)begin
								WrEn = 1'b1;
								Arow = ROWBITS'(i); // row 0 is the verilog's index 7 of the A matrix
								Ain = A[DIM - 1 - i]; // from first row (7th index)
							end
					end
            
					@(negedge clk)
						WrEn = 1'b0; // Stop writing into the memA array rows
									
					for(int i=0; i<3*DIM-2; ++i)begin
						@(negedge clk) begin
							Aout[mycycle] = Aout_tmp;
							en = 1'b1;  // enables the memA, memA should start shifting out values
							mycycle = matc.next_cycle();
						end
					end
					
					// Compare matrix
					errors = matc.compareMatRow(Aout);
					
					if(errors > 0)
						$display("Mission Failed! Please check files and make changes");
					else
						$display("Mission Successful!!! All tests passed");
					
					// TODO: Dump it to visualize it
					matc.dump(Aout);
        end
				
				$stop;
    end
endmodule