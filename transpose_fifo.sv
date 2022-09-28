module transpose_fifo  #(
  parameter DEPTH=8,
  parameter BITS=8
  )
  (
  input clk,rst_n, en, Arow, WrEn,
  input [BITS-1:0] Ain [DEPTH-1:0], 
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
			if(i == DEPTH - 1)
				fifo[DEPTH-1] <= '0;
			else
				fifo[i] <= fifo[i+1];
		end
	end

  end


  assign Aout = fifo[0];

endmodule