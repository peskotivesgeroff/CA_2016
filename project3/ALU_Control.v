module ALU_Control
(
    funct_i,
    ALUOp_i,
    ALUCtrl_o
);

// Ports
input   [5:0]       funct_i;
input   [1:0]       ALUOp_i;
output  [2:0]      	ALUCtrl_o;

reg		[2:0]      	ALUCtrl_o;

always@(funct_i or ALUOp_i) begin
    case (ALUOp_i)
		2'b00 :				ALUCtrl_o = 3'b010; //ADD
		2'b10 : begin
			case(funct_i)
				6'b100000 :	ALUCtrl_o = 3'b010; //ADD
				6'b100010 :	ALUCtrl_o = 3'b110; //SUB
				6'b100100 :	ALUCtrl_o = 3'b000; //AND
				6'b100101 :	ALUCtrl_o = 3'b001; //OR
				6'b011000 :	ALUCtrl_o = 3'b011; //MUL
				default	  : ALUCtrl_o = 3'b111;
			endcase
		end
		default: 			ALUCtrl_o = 3'b111;
	endcase
end

endmodule
