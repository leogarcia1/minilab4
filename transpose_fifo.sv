module transpose_fifo  #(
  parameter DEPTH=8,
  parameter BITS=8
  )
  (
  input clk,rst_n, en, Arow, WrEn,
  input [BITS-1:0] Ain [DEPTH-1:0],  // In matrix first row [5, 4, 2, 1, ...], 5 is matrix 00 which is Ain[7] in verilog
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
		fifo <= Ain;
	end

	else if(en) begin
		for(integer i = 0; i < DEPTH; i++) begin
			if(i == 0)
				fifo[0] <= '0;
			else
				fifo[DEPTH - 1 - i] <= fifo[DEPTH - 1 - i - 1];
		end
	end

  end

	
  assign Aout = fifo[7];

endmodule