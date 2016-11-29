module Control
(
    Op_i,
    RegDst_o,
    ALUSrc_o,
    MemtoReg_o,
    RegWrite_o,
    MemRead_o,
    MemWrite_o,
    Branch_o,
    Jump_o,
    ALUOp_o
);

input   [5:0]       Op_i;
output              RegDst_o, ALUSrc_o, MemtoReg_o, RegWrite_o, MemRead_o, MemWrite_o, Branch_o, Jump_o;
output	[1:0]		ALUOp_o;

reg					RegDst_o, ALUSrc_o, MemtoReg_o, RegWrite_o, MemRead_o, MemWrite_o, Branch_o, Jump_o;
reg		[1:0]		ALUOp_o;

initial Branch_o = 1'b0;
initial Jump_o = 1'b0;

always@(Op_i) begin
    case (Op_i)
		6'b000000 : begin	//R-type
			RegDst_o 	= 1'b1;
			ALUSrc_o 	= 1'b0;
			MemtoReg_o	= 1'b0;
			RegWrite_o 	= 1'b1;
			MemRead_o	= 1'b0;
			MemWrite_o	= 1'b0;
			Branch_o	= 1'b0;
			Jump_o		= 1'b0;
			ALUOp_o		= 2'b10;
		end
		6'b001000 : begin	//addi
			RegDst_o 	= 1'b0;
			ALUSrc_o 	= 1'b1;
			MemtoReg_o	= 1'b0;
			RegWrite_o 	= 1'b1;
			MemRead_o	= 1'b0;
			MemWrite_o	= 1'b0;
			Branch_o	= 1'b0;
			Jump_o		= 1'b0;
			ALUOp_o		= 2'b00;
		end
		6'b001000 : begin	//lw
			RegDst_o 	= 1'b0;
			ALUSrc_o 	= 1'b1;
			MemtoReg_o	= 1'b1;
			RegWrite_o 	= 1'b1;
			MemRead_o	= 1'b1;
			MemWrite_o	= 1'b0;
			Branch_o	= 1'b0;
			Jump_o		= 1'b0;
			ALUOp_o		= 2'b00;
		end
		6'b001000 : begin	//sw
			RegDst_o 	= 1'bx;
			ALUSrc_o 	= 1'b1;
			MemtoReg_o	= 1'bx;
			RegWrite_o 	= 1'b0;
			MemRead_o	= 1'b0;
			MemWrite_o	= 1'b1;
			Branch_o	= 1'b0;
			Jump_o		= 1'b0;
			ALUOp_o		= 2'b00;
		end
		6'b001000 : begin	//beq
			RegDst_o 	= 1'bx;
			ALUSrc_o 	= 1'b0;
			MemtoReg_o	= 1'bx;
			RegWrite_o 	= 1'b0;
			MemRead_o	= 1'b0;
			MemWrite_o	= 1'b0;
			Branch_o	= 1'b1;
			Jump_o		= 1'b0;
			ALUOp_o		= 2'b11;
		end
		6'b001000 : begin	//j
			RegDst_o 	= 1'bx;
			ALUSrc_o 	= 1'bx;
			MemtoReg_o	= 1'bx;
			RegWrite_o 	= 1'b0;
			MemRead_o	= 1'b0;
			MemWrite_o	= 1'b0;
			Branch_o	= 1'b0;
			Jump_o		= 1'b1;
			ALUOp_o		= 2'b11;
		end
		default   : begin
			RegDst_o 	= 1'bx;
			ALUSrc_o 	= 1'bx;
			ALUOp_o		= 2'b11;
		end
	endcase
end

endmodule
