module ALU
(
    data1_i,
    data2_i,
    ALUCtrl_i,
    data_o
);

input   [31:0]      data1_i, data2_i;
input   [2:0]       ALUCtrl_i;
output  [31:0]      data_o;

reg     [31:0]      data_o;

assign Zero_o = 1'b0;

always@(data1_i or data2_i or ALUCtrl_i) begin
    case (ALUCtrl_i)
		3'b000	:	data_o = data1_i & data2_i;
		3'b001	:	data_o = data1_i | data2_i;
		3'b010	:	data_o = data1_i + data2_i;
		3'b110	:	data_o = data1_i - data2_i;
		3'b011	:	data_o = data1_i * data2_i;
		default :	data_o = 32'b0;
	endcase
end

endmodule
