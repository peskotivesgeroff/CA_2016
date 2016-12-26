module MEM_WB
(
    clk_i,
    MemtoReg_i,
    RegWrite_i,

    Memdata_i,
    ALUresult_i,
    RDaddr_i,
	stall_i,

    MemtoReg_o,
    RegWrite_o,

    Memdata_o,
    ALUresult_o,
    RDaddr_o
);

// Ports
input               clk_i, MemtoReg_i, RegWrite_i, stall_i;
input   [4:0]       RDaddr_i;
input   [31:0]      Memdata_i, ALUresult_i;
output				MemtoReg_o, RegWrite_o;
output  [4:0]       RDaddr_o;
output  [31:0]      Memdata_o, ALUresult_o;

reg					MemtoReg_o, RegWrite_o;
reg  [4:0]       	RDaddr_o;
reg  [31:0]      	Memdata_o, ALUresult_o;

initial begin
	MemtoReg_o = 1'b0;
	RegWrite_o = 1'b0;
end

always@(posedge clk_i) begin
	if(~stall_i) begin
    	MemtoReg_o <= MemtoReg_i;
    	RegWrite_o <= RegWrite_i;
    	RDaddr_o <= RDaddr_i;
    	Memdata_o <= Memdata_i;
    	ALUresult_o <= ALUresult_i;
	end
	else begin
    	MemtoReg_o <= MemtoReg_o;
    	RegWrite_o <= RegWrite_o;
    	RDaddr_o <= RDaddr_o;
    	Memdata_o <= Memdata_o;
    	ALUresult_o <= ALUresult_o;
	end
    //$display("RDaddr: %b", RDaddr_o);
end

endmodule
