module transpose_fifo  #(
  parameter DEPTH=8,
	parameter DIM=8,
  parameter BITS=8
  )
  (
  input clk,rst_n, en, WrEn,
  input [BITS-1:0] Ain [DIM-1:0],  // In matrix first row [5, 4, 2, 1, ...], 5 is matrix 00 which is Ain[7] in verilog
  output [BITS-1:0] Aout
  );

  logic [BITS-1:0] fifo [DEPTH-1:0];

  always @(posedge clk, negedge rst_n) begin
		if(!rst_n) begin
			for(integer i = 0; i < DEPTH; i++) begin
				fifo[i] <= '0; 
			end
		end
		else if(WrEn) begin
			fifo[BITS-1:0] <= Ain; // write to end of fifo
		end
		else if(en) begin
			for(integer i = DEPTH -1; i >= 0; i--) begin
				if(i == 0)
					fifo[0] <= '0;
				else
					fifo[i] <= fifo[i - 1];
			end
		end
  end

	// Get values from head
  assign Aout = fifo[DEPTH-1];

endmodule