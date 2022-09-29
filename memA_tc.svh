class memA_tc #(parameter BITS_AB=8,
                parameter DIM=8);

bit signed [BITS_AB-1:0] A [DIM-1:0][DIM-1:0];
int cycle;

function new();
    for (int i=0; i<DIM; i++)begin
        for (int j=0; j<DIM; j++)begin
            A[i][j] = 0;
        end
    end
    cycle = 0;
endfunction: new

function bit signed [DIM-1:0][DIM-1:0][BITS_AB-1:0] new_matrix();
    int A_val;
    bit signed [DIM-1:0][DIM-1:0][BITS_AB-1:0]A_tmp;
    // Randomize A and return a matrix of random values
    for (int row=0; row<DIM; ++row)begin
        for (int col=0; col<DIM; ++col)begin
            A_val = $urandom();
            A_tmp[row][col][7:0] = {A_val[7:0]};
            A[row][col] = A_tmp[row][col][7:0];
        end
    end
    return A_tmp;
endfunction: new_matrix

function int next_cycle();
    cycle = cycle + 1;
    return cycle;
endfunction: next_cycle

function void dump(logic signed [BITS_AB-1:0]memA_test[DIM:0][3*DIM-2-1:0]);
    // display memA for debugging purposes
    $display("memA:\n");
    for(int row=0;row<DIM;++row) begin
        for(int col=0; col<DIM; ++col)begin
            $write("%5d ",memA_test[row][col]);
        end
    end
endfunction: dump
endclass