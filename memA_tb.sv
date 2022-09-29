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
    logic signed [BITS_AB-1:0] Aout [DIM-1:0][3*DIM-2-1:0];
    // Temporary value that stores the value coming out of memA
    logic signed [BITS_AB-1:0] Aout_tmp [DIM-1:0];

    // Generate clock
    always #5 clk = ~clk;

    // Keep track of how many errors and which cycle is the tb in
    integer errors, mycycle;

    // Instantiate the device under test
    memA #(.BITS_AB(BITS_AB), .DIM(DIM)) iDUT(.clk(clk), .rst_n(rst_n), .en(en), .WrEn(WrEn), .Ain(Ain), .Arow(Arow), .Aout(Aout_tmp));
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
        //----------- INITIALIZE BLOCK: Initialize values in different matrices to 0 ------------
        // reset and check Cout
        @(posedge clk) begin end
        rst_n = 1'b0; // active low reset
        @(posedge clk) begin end
        rst_n = 1'b1; // reset finished
        @(posedge clk) begin
            // Initialize values in different matrices to 0
            for(int rowcol=0;rowcol<DIM;++rowcol) begin
                A[rowcol] = {BITS_AB{1'b0}};
                Aout_tmp[rowcol] = {BITS_AB{1'b0}};
            end
            for(int row=0; row<DIM; row++) begin
                for(int col=0; col<DIM; col++) begin
                    Aout[row][col] = {BITS_AB{1'b0}};
                end
            end
        end
        //----------- END INITIALIZE BLOCK: Initialize values in different matrices to 0 ------------
        //----------- TESTING BLOCK: test memA behavior MULTIPLE TIMES using different random value matrices ------------
        for(int test=0; test<TESTS; test++)begin
            A = matc.new_matrix();  // Generate new random values to test memA
            // Start writing values into the memA module
            @(negedge clk) begin
                WrEn = 1'b1;
            end
            // Load values from register into memA that will be tested
            @(posedge clk) begin
                for(int i=0; i<DIM; ++i)begin
                    @(posedge clk)begin
                        Arow = i;
                    end
                end
            end
            // Stop writing into the memA; start letting memA shifting values out of it.
            @(negedge clk) begin
                WrEn = 1'b0;
                en = 1'b1;  // enables the memA, memA should start shifting out values
            end
            @(posedge clk) begin
                for(int col=0; col<DIM; ++col)begin
                    for(int row=0; row<DIM; ++row)begin
                        Aout[row][mycycle] = Aout_tmp[row];
                    end
                    @(posedge clk) begin
                        mycycle = matc.next_cycle();
                    end
                end
            end
            // TODO: Dump it to visualize it
            matc.dump(Aout);
        end
    end
endmodule