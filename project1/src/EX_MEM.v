module EX_MEM
(
    clk_i,
	MemRead_i,
    MemWrite_i,
    MemtoReg_i,
    RegWrite_i,

    ALUresult_i,
    RDdata_i,
    RDaddr_i,

    MemRead_o,
    MemWrite_o,
    MemtoReg_o,
    RegWrite_o,

    ALUresult_o,
    RDdata_o,
    RDaddr_o
);

// Ports
input               clk_i, MemRead_i, MemWrite_i, MemtoReg_i, RegWrite_i;
input   [4:0]       RDaddr_i;
input   [31:0]      ALUresult_i, RDdata_i;
output				MemRead_o, MemWrite_o, MemtoReg_o, RegWrite_o;
output 	[4:0]		RDaddr_o;
output	[31:0]		ALUresult_o, RDdata_o;

reg					MemRead_o, MemWrite_o, MemtoReg_o, RegWrite_o;
reg 	[4:0]		RDaddr_o;
reg		[31:0]		ALUresult_o, RDdata_o;

initial begin
	MemRead_o = 1'b0;
	MemWrite_o = 1'b0;
	MemtoReg_o = 1'b0;
	RegWrite_o = 1'b0;
end


always@(posedge clk_i) begin
    MemRead_o <= MemRead_i;
    MemWrite_o <= MemWrite_i;
    MemtoReg_o <= MemtoReg_i;
    RegWrite_o <= RegWrite_i;
    RDaddr_o <= RDaddr_i;
    ALUresult_o <= ALUresult_i;
    RDdata_o <= RDdata_i;
end

endmodule
