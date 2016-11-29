module PC
(
    clk_i,
    start_i,
    PCWrite_i,
    pc_i,
    pc_o
);

// Ports
input               clk_i, start_i, PCWrite_i;
input   [31:0]      pc_i;
output  [31:0]      pc_o;

// Wires & Registers
reg     [31:0]      pc_o;


always@(posedge clk_i) begin
  //$display("start: %d", start_i);
  //$display("PC write: %d", PCWrite_i);
  //$display("PC i: %d", pc_i);
  if(start_i && PCWrite_i)
		pc_o <= pc_i;
	else
		pc_o <= pc_o;

end

endmodule
