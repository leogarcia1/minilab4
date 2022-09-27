// memA test bench

`include "systolic_array_tc.svh"

module memA_tb();

    localparam BITS_AB=8;
    localparam BITS_C=16;
    localparam DIM=8;
    localparam ROWBITS=$clog2(DIM);

    localparam TESTS=16;

    // Clock
    logic clk;
    logic rst_n;
    logic en;
    logic WrEn;
    logic [ROWBITS-1:0] Arow;
    logic signed [BITS_AB-1:0] A [DIM-1:0];
    logic signed [BITS_C-1:0] Aout [DIM-1:0];

    always #5 clk = ~clk;

    memA iDUT(.clk(clk), .rst_n(rst_n), .en(en), .WrEn(WrEn), .Ain(A), .Arow(Crow), .Aout(Aout));

    integer errors,mycycle;

    systolic_array #(.BITS_AB(BITS_AB),
                    .BITS_C(BITS_C),
                    .DIM(DIM)
                    ) DUT (.*);

    systolic_array_tc #(.BITS_AB(BITS_AB),
                        .BITS_C(BITS_C),
                        .DIM(DIM)
                        ) satc;

    // register Cout values
    always @(posedge clk) begin
        Coutreg <= Cout;
    end

    initial begin
        clk = 1'b0;
        rst_n = 1'b1;
        en = 1'b0;
        WrEn = 1'b0;
        errors = 0;
        Crow = {ROWBITS{1'b0}};
        for(int rowcol=0;rowcol<DIM;++rowcol) begin
            A[rowcol] = {BITS_AB{1'b0}};
            B[rowcol] = {BITS_AB{1'b0}};
            Cin[rowcol] = {BITS_C{1'b0}};
        end
        // reset and check Cout
        @(posedge clk) begin end
        rst_n = 1'b0; // active low reset
        @(posedge clk) begin end
        rst_n = 1'b1; // reset finished
        @(posedge clk) begin end

        // check that C was properly reset
        for(int Row=0;Row<DIM;++Row) begin
            Crow = {Row[ROWBITS-1:0]};
            @(posedge clk) begin end
            for(int Col=0;Col<DIM;++Col) begin
            if(Coutreg[Col] !== 0) begin
                    errors++;
                    $display("Error! Reset was not conducted properly. Expected: 0, Got: %d for Row %d Col %d", Coutreg[Col],Row, Col); 
                end
            end
        end
    end