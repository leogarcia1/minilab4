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
        output signed [BITS_AB-1:0] Aout [DIM-1:0]
    );

    // Take the element coming out of each FIFO buffer as output of this module
    logic signed [BITS_AB-1:0] Aout_tmp [DIM-1:0];
    // write only to the row selected by Arow
    logic write;
    // generate a list of transpose fifo modules that pads zeroes to put the data into rhombus shape
    genvar row, col;
    generate
        for (row=0; row<DIM; ++row) begin
            assign write = (Arow == row) ? WrEn : 0;
            transpose_fifo tf(.clk(clk),.rst_n(rst_n),.en(en),.WrEn(write),.Ain(Ain[row]),.Aout(Aout_tmp[row]));
        end
    endgenerate

    assign Aout = Aout_tmp;

endmodule