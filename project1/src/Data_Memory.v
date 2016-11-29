module Data_Memory
(
    addr_i,
	data_i,
	MemRead_i,
	MemWrite_i,
    data_o
);

// Interface
input   [31:0]      addr_i, data_i;
input				MemRead_i, MemWrite_i;
output  [31:0]      data_o;

// Instruction memory
reg     [7:0]     	memory  [0:31]; //why 8 bits?
reg 	[31:0]		data_o;

always@(MemRead_i or MemWrite_i) begin
    if(MemRead_i)
        data_o = {{24'b0}, memory[addr_i>>2]};
	else begin
		data_o = 32'b0;
		if(MemWrite_i)
			memory[addr_i>>2] = data_i[7:0];
	end
end

endmodule
