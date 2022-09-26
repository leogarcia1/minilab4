module transpose_fifo  #(
	parameter DEPTH=8,
	parameter BITS=8
)
(
	input clk,rst_n, en, WrEn,
	input [$clog2(DEPTH)-1:0] Arow,
	input [BITS-1:0] Ain [DEPTH-1:0], 
	output [BITS-1:0] Aout
);

  logic [BITS-1:0] fifo [DEPTH-1:0];

// Make 8 FIFO modules each has 8 bits to store matrix data which will later be pumped to delayFIFO
  always @(posedge clk, negedge rst_n) begin
	// Reset the fifo modules on negative reset
	if(!rst_n) begin
		for(integer i = 0; i < DEPTH; i++) begin
			fifo[i] <= '0; 
		end
	end
	// Parallel write 8 bits data into fifo at WrEn
	else if(WrEn) begin
		fifo <= Ain;
	end
	// If enabled, pipeline the data to delayFIFO which appends zeroes to form rhombus shape.
	else if(en) begin
		for(integer i = 0; i < DEPTH; i++) begin
			if(i == DEPTH - 1)
				fifo[DEPTH-1] <= '0;
			else
				fifo[i] <= fifo[i+1];
		end
	end
	
  end

  genvar row, col;
  generate
	for(row=0; row<BITS; ++row) begin
		fifo df1(.clk(clk), .rst_n(rst_n), .en(en), .d(fifo[row]), .q());
  	end
  endgenerate


  assign Aout = fifo[0];

endmodule