module ID_EX
(
    clk_i,
	RegDst_i,
    ALUSrc_i,
    ALUOp_i,
    MemRead_i,
    MemWrite_i,
    MemtoReg_i,
    RegWrite_i,

    RSdata_i,
    RTdata_i,
    immediate_i,
    RSaddr_i,
    RTaddr_i,
    RDaddr_i,

    RegDst_o,
    ALUSrc_o,
    ALUOp_o,
    MemRead_o,
    MemWrite_o,
    MemtoReg_o,
    RegWrite_o,

    RSdata_o,
    RTdata_o,
    immediate_o,
    RSaddr_o,
    RTaddr_o,
    RDaddr_o
);

input               clk_i, RegDst_i, ALUSrc_i, MemRead_i, MemWrite_i, MemtoReg_i, RegWrite_i;
input 	[1:0]		ALUOp_i;
input   [4:0]       RSaddr_i, RTaddr_i, RDaddr_i;
input   [31:0]      immediate_i, RSdata_i, RTdata_i;
output				RegDst_o, ALUSrc_o, MemRead_o, MemWrite_o, MemtoReg_o, RegWrite_o;
output 	[1:0]		ALUOp_o;
output  [4:0]		RSaddr_o, RTaddr_o, RDaddr_o;
output  [31:0]      RSdata_o, RTdata_o, immediate_o;

reg					RegDst_o, ALUSrc_o, MemRead_o, MemWrite_o, MemtoReg_o, RegWrite_o;
reg 	[1:0]		ALUOp_o;
reg  	[4:0]		RSaddr_o, RTaddr_o, RDaddr_o;
reg  	[31:0]      RSdata_o, RTdata_o, immediate_o;

always@(posedge clk_i) begin
	RegDst_o <= RegDst_i;
	ALUSrc_o <= ALUSrc_i;
	MemRead_o <= MemRead_i;
	MemWrite_o <= MemWrite_i;
	MemtoReg_o <= MemtoReg_i;
	RegWrite_o <= RegWrite_i;
    ALUOp_o <= ALUOp_i;
    RSaddr_o <= RSaddr_i;
	RTaddr_o <= RTaddr_i;
	RDaddr_o <= RDaddr_i;
	RSdata_o <= RSdata_i;
	RTdata_o <= RTdata_i;
	immediate_o <= immediate_i;
  $display("rs_addr_o: %b", RSaddr_o);
  $display("rt_addr_o: %b", RTaddr_o);
  $display("rd_addr_o: %b", RDaddr_o);
end

endmodule
