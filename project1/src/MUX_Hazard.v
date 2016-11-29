module MUX_Hazard
(
    RegDst_i,
    ALUSrc_i,
    ALUOp_i,
    MemRead_i,
    MemWrite_i,
    MemtoReg_i,
    RegWrite_i,
    select_i,

    RegDst_o,
    ALUSrc_o,
    ALUOp_o,
    MemRead_o,
    MemWrite_o,
    MemtoReg_o,
    RegWrite_o
);

input   [1:0]		ALUOp_i;
input				RegDst_i, ALUSrc_i, MemRead_i, MemWrite_i, MemtoReg_i, RegWrite_i, select_i;
output  [1:0]		ALUOp_o;
output				RegDst_o, ALUSrc_o, MemRead_o, MemWrite_o, MemtoReg_o, RegWrite_o;

reg		[1:0]		ALUOp_o;
reg					RegDst_o, ALUSrc_o, MemRead_o, MemWrite_o, MemtoReg_o, RegWrite_o;

always@(*) begin
    if(select_i) begin
		RegDst_o = 1'b0;
		ALUSrc_o = 1'b0;
		ALUOp_o  = 2'b0;
		MemRead_o = 1'b0;
		MemWrite_o = 1'b0;
		MemtoReg_o = 1'b0;
		RegWrite_o = 1'b0;
    end
	else begin
		RegDst_o = RegDst_i;
		ALUSrc_o = ALUSrc_i;
		ALUOp_o  = ALUOp_i;
		MemRead_o = MemRead_i;
		MemWrite_o = MemWrite_i;
		MemtoReg_o = MemtoReg_i;
		RegWrite_o = RegWrite_i;
	end

end

endmodule
