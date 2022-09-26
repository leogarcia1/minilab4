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

    logic signed [BITS_AB-1:0] Ain_tmp [DIM-1:0] [DIM-1:0];
    logic write;

    genvar row, col;
    generate
        for (row=0; row<DIM; ++row) begin
            assign write = (Arow == row) ? WrEn : 0;
            transpose_fifo tf(.clk(clk),.rst_n(rst_n),.en(en),.WrEn(write),.Ain(Ain[row]),.Aout(Aout[row][0]));
            
        end
    endgenerate

    // transpose_fifo

endmodule