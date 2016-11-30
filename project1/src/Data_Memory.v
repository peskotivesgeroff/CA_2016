module Data_Memory
(
  addr_i,
  data_i,
  MemRead_i,
  MemWrite_i,
  data_o,
  clk_i
);

// Interface
input   [31:0]      addr_i, data_i;
input				MemRead_i, MemWrite_i, clk_i;
output  [31:0]      data_o;

assign  data_o = MemRead_i ? {memory[addr_i+3], memory[addr_i+2], memory[addr_i+1], memory[addr_i]} : 32'b0;

// Instruction memory
reg     [7:0]     	memory  [0:31]; //why 8 bits?
//reg 	[31:0]		data_o;

always@(negedge clk_i) begin
  if(MemWrite_i) begin 
      memory[addr_i] <= data_i[7:0];
      memory[addr_i+1] <= data_i[15:8];
      memory[addr_i+2] <= data_i[23:16];
      memory[addr_i+3] <= data_i[31:24];
  end
end

endmodule
